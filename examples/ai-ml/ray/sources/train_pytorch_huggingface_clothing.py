import ray
import argparse
import logging
import math
import os
os.environ["TOKENIZERS_PARALLELISM"] = "true"
from ray import train
from typing import Dict, Any
import random
import torch
import datasets
import ray
import transformers
from accelerate import Accelerator
from datasets import load_dataset, load_metric
from torch.utils.data.dataloader import DataLoader
import tempfile
from ray.air import session, Checkpoint
from tqdm.auto import tqdm
from ray.train.torch import TorchTrainer
from ray.train.huggingface import HuggingFaceTrainer
from ray.air.config import ScalingConfig, RunConfig
from ray.tune import SyncConfig
import boto3

from transformers import (
    AdamW,
    AutoConfig,
    AutoModelForSequenceClassification,
    AutoTokenizer,
    DataCollatorWithPadding,
    PretrainedConfig,
    SchedulerType,
    default_data_collator,
    get_scheduler,
    set_seed,
)
from transformers.utils.versions import require_version

S3_BUCKET=os.environ["S3_BUCKET"]

def train_func():
    model_name_or_path = "roberta-base"
    use_slow_tokenizer = False
    per_device_train_batch_size = 64
    learning_rate = 5e-5
    weight_decay = 0.0
    num_train_epochs = 1
    max_train_steps = 1
    gradient_accumulation_steps = 1
    lr_scheduler_type = "linear"
    num_warmup_steps = 0
    output_dir = None
    seed = None
    num_workers = 20
    use_gpu = False
    max_length = 64

    accelerator = Accelerator()

    import s3fs

    s3_file = s3fs.S3FileSystem()
    s3_path = f"{S3_BUCKET}/data"
    data_path = tempfile.mkdtemp()
    s3_file.get(s3_path, data_path, recursive=True)

    data_files = {}
    data_files["train"] = f"{data_path}/test/part-algo-1-womens_clothing_ecommerce_reviews.csv"
    extension = "csv"

    raw_datasets = load_dataset(extension, data_files=data_files)

    label_list = raw_datasets["train"].unique("sentiment")

    # Sort for determinism
    label_list.sort()

    num_labels = len(label_list)

    config = AutoConfig.from_pretrained(
        model_name_or_path, num_labels=num_labels,
    )
    tokenizer = AutoTokenizer.from_pretrained(
        model_name_or_path, use_fast=not use_slow_tokenizer
    )
    model = AutoModelForSequenceClassification.from_pretrained(
        model_name_or_path,
        config=config,
    )

    sentence1_key, sentence2_key = "review_body", None

    label_to_id = None
    label_to_id = {v: i for i, v in enumerate(label_list)}

    if label_to_id is not None:
        model.config.label2id = label_to_id
        model.config.id2label = {id: label for label, id in config.label2id.items()}

    def preprocess_function(examples):
        texts = (
            (examples[sentence1_key],)
            if sentence2_key is None
            else (examples[sentence1_key], examples[sentence2_key])
        )
        result = tokenizer(
            *texts, padding="max_length", max_length=max_length, truncation=True
        )

        if "sentiment" in examples:
            if label_to_id is not None:
                result["labels"] = [
                    label_to_id[l] for l in examples["sentiment"]
                ]
            else:
                result["labels"] = examples["sentiment"]

        return result

    processed_datasets = raw_datasets.map(
        preprocess_function,
        batched=True,
        remove_columns=raw_datasets["train"].column_names,
        desc="Running tokenizer on dataset",
    )

    train_dataset = processed_datasets["train"]

    train_dataloader = DataLoader(
        train_dataset,
        shuffle=True,
        collate_fn=default_data_collator,
        batch_size=per_device_train_batch_size,
    )

    no_decay = ["bias", "LayerNorm.weight"]
    optimizer_grouped_parameters = [
        {
            "params": [
                p
                for n, p in model.named_parameters()
                if not any(nd in n for nd in no_decay)
            ],
            "weight_decay": weight_decay,
        },
        {
            "params": [
                p
                for n, p in model.named_parameters()
                if any(nd in n for nd in no_decay)
            ],
            "weight_decay": 0.0,
        },
    ]

    optimizer = AdamW(optimizer_grouped_parameters, lr=learning_rate)

    model, optimizer, train_dataloader = accelerator.prepare(
       model, optimizer, train_dataloader
    )

    num_update_steps_per_epoch = math.ceil(
        len(train_dataloader) / gradient_accumulation_steps
    )
    if max_train_steps is None:
        max_train_steps = num_train_epochs * num_update_steps_per_epoch
    else:
        num_train_epochs = math.ceil(
            max_train_steps / num_update_steps_per_epoch
        )

    lr_scheduler = get_scheduler(
        name=lr_scheduler_type,
        optimizer=optimizer,
        num_warmup_steps=num_warmup_steps,
        num_training_steps=max_train_steps,
    )

    metric = load_metric("accuracy")

    total_batch_size = (
        per_device_train_batch_size
        * accelerator.num_processes
        * gradient_accumulation_steps
    )

    print("***** Training *****")
    print(f"  Num examples = {len(train_dataset)}")
    print(f"  Num epochs = {num_train_epochs}")
    print(
        f"  Instantaneous batch size per device ="
        f" {per_device_train_batch_size}"
    )
    print(
        f"  Total train batch size (w. parallel, distributed & accumulation) "
        f"= {total_batch_size}"
    )
    print(f"  Gradient Accumulation steps = {gradient_accumulation_steps}")
    print(f"  Total optimization steps = {max_train_steps}")

    progress_bar = tqdm(
        range(max_train_steps), disable=not accelerator.is_local_main_process
    )
    completed_steps = 0

    running_train_loss = 0.0

    model = train.torch.prepare_model(model)

    for epoch in range(num_train_epochs):
        model.train()
        for step, batch in enumerate(train_dataloader):
            outputs = model(**batch)
            loss = outputs.loss

            running_train_loss += loss

            loss = loss / gradient_accumulation_steps
            accelerator.backward(loss)
            if (
                step % gradient_accumulation_steps == 0
                or step == len(train_dataloader) - 1
            ):
                optimizer.step()
                lr_scheduler.step()
                optimizer.zero_grad()
                progress_bar.update(1)
                completed_steps += 1

            if completed_steps >= max_train_steps:
                break

        session.report(
            {
                "running_train_loss": running_train_loss,
            },
            checkpoint=Checkpoint.from_dict(dict(model=model.module.state_dict()))
        )

    if output_dir is not None:
        accelerator.wait_for_everyone()
        unwrapped_model = accelerator.unwrap_model(model)
        unwrapped_model.save_pretrained(output_dir, save_function=accelerator.save)


ray.shutdown()
ray.init(address="ray://raycluster-autoscaler-head-svc:10001",
         runtime_env={"pip": [
                                "torch",
                                "scikit-learn",
                                "transformers",
                                "pandas",
                                "datasets",
                                "accelerate",
                                "scikit-learn",
                                "mlflow",
                                "tensorboard",
                                "s3fs",
                             ]
                     }
        )

s3_checkpoint_prefix=f"{S3_BUCKET}/ray_output"


trainer = TorchTrainer(
    train_loop_per_worker=train_func,
    train_loop_config={
                        "batch_size": 64,
                        "epochs": 10
                      },
    # Increase num_workers to scale out the cluster
    scaling_config=ScalingConfig(num_workers=2),
    run_config = RunConfig(
        sync_config=SyncConfig(
            # This will store checkpoints in S3.
            upload_dir=s3_checkpoint_prefix
        )
    )
)

results = trainer.fit()
print(results.metrics)

ssm = boto3.client('ssm')
s3_uri = f"{s3_checkpoint_prefix}/{results.log_dir.as_posix().split('/')[-2]}/{results.log_dir.as_posix().split('/')[-1]}/checkpoint_000000/"
ssm.put_parameter(
    Name="/ray-demo/model_checkpoint",
    Type="String",
    Overwrite=True,
    Value=s3_uri
)

print(s3_uri)

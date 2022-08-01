# Source: https://www.tensorflow.org/tutorials/load_data/images
import numpy as np
import tensorflow as tf

from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.models import Sequential

DATA_DIR = "/train/.keras/datasets/flower_photos"
IMG_HEIGHT = 180
IMG_WIDTH = 180
BATCH_SIZE = 32

def create_model(num_classes):
    model = Sequential([
    layers.Rescaling(1./255, input_shape=(IMG_HEIGHT, IMG_WIDTH, 3)),
    layers.Conv2D(16, 3, padding='same', activation='relu'),
    layers.MaxPooling2D(),
    layers.Conv2D(32, 3, padding='same', activation='relu'),
    layers.MaxPooling2D(),
    layers.Conv2D(64, 3, padding='same', activation='relu'),
    layers.MaxPooling2D(),
    layers.Flatten(),
    layers.Dense(128, activation='relu'),
    layers.Dense(num_classes)
    ])

    model.compile(optimizer='adam',
                loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
                metrics=['accuracy'])

    # Print the model details
    model.summary()

    return model

def get_data_split(subset_type):
    ds = tf.keras.utils.image_dataset_from_directory(
    DATA_DIR,
    validation_split=0.2,
    subset=subset_type,
    seed=123,
    image_size=(IMG_HEIGHT, IMG_WIDTH),
    batch_size=BATCH_SIZE)

    return ds

def main():    
    # Define the datasets based on images already loaded onto the EFS Volume
    train_ds = get_data_split("training")
    val_ds = get_data_split("validation")

    class_names = train_ds.class_names
    print(class_names)

    AUTOTUNE = tf.data.AUTOTUNE
    train_ds = train_ds.cache().shuffle(1000).prefetch(buffer_size=AUTOTUNE)
    val_ds = val_ds.cache().prefetch(buffer_size=AUTOTUNE)

    # Define and Compile the model
    num_classes = len(class_names)
    model = create_model(num_classes)

    # Training
    epochs = 2
    history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=epochs
    )

if __name__ == '__main__':
    main()
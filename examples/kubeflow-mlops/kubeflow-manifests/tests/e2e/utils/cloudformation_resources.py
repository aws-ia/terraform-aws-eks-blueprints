from e2e.utils.config import configure_resource_fixture


def create_stack(
    cfn_client,
    template_path,
    stack_name,
    params={},
    capabilities=[],
    timeout=300,
    interval=30,
):
    """
    Creates a cloudformation stack from a cloudformation template
    """

    with open(template_path) as file:
        body = file.read()

    stack_params = [
        {"ParameterKey": key, "ParameterValue": value, "UsePreviousValue": False}
        for key, value in params.items()
    ]

    resp = cfn_client.create_stack(
        StackName=stack_name,
        TemplateBody=body,
        Parameters=stack_params,
        Capabilities=capabilities,
    )

    stack_id = resp["StackId"]

    print(f"Creating stack {stack_name}, waiting for stack create complete")
    waiter = cfn_client.get_waiter("stack_create_complete")
    waiter.wait(
        StackName=stack_name,
        WaiterConfig={"Delay": interval, "MaxAttempts": timeout // interval + 1},
    )

    return stack_name, stack_id


def delete_stack(cfn_client, stack_name, timeout=300, interval=10):
    """
    Deletes a cloudformation stack
    """

    cfn_client.delete_stack(StackName=stack_name)

    print(f"Deleting stack {stack_name}, waiting for stack delete complete")
    waiter = cfn_client.get_waiter("stack_delete_complete")
    waiter.wait(
        StackName=stack_name,
        WaiterConfig={"Delay": interval, "MaxAttempts": timeout // interval + 1},
    )


def describe_stack(cfn_client, stack_name):
    """
    Describes a cloudformation stack
    """

    return cfn_client.describe_stacks(StackName=stack_name)["Stacks"][0]


def get_stack_outputs(cfn_client, stack_name):
    """
    Cloudformation stacks can be configured to output certain values upon stack
    creation, such as an RDS endpoint URL or S3 bucket name.

    This function returns the outputs of a stack as a dictionary.
    """

    resp = describe_stack(cfn_client, stack_name)

    return {o["OutputKey"]: o["OutputValue"] for o in resp["Outputs"]}


def create_cloudformation_fixture(
    metadata,
    request,
    cfn_client,
    template_path,
    stack_name,
    metadata_key,
    params={},
    capabilities=[],
    create_timeout=300,
    create_interval=10,
    delete_timeout=300,
    delete_interval=10,
):
    """
    Helper function to create a cloudformation fixture.

    Takes care of adding the resource details to the metadata and creating and tearing
    down the stack.
    """

    resource_details = {"stack_name": stack_name, "params": params}

    def on_create():
        create_stack(
            cfn_client=cfn_client,
            template_path=template_path,
            stack_name=stack_name,
            params=params,
            capabilities=capabilities,
            timeout=create_timeout,
            interval=create_interval,
        )

    def on_delete():
        details = metadata.get(metadata_key) or resource_details

        delete_stack(
            cfn_client=cfn_client,
            stack_name=details["stack_name"],
            timeout=delete_timeout,
            interval=delete_interval,
        )

    return configure_resource_fixture(
        metadata=metadata,
        request=request,
        resource_details=resource_details,
        metadata_key=metadata_key,
        on_create=on_create,
        on_delete=on_delete,
    )

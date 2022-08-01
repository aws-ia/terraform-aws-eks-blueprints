from kubernetes import client, watch


def wait_created_cr(name, namespace, group, version, plural, timeout):
    """Wait until the specified CR gets created."""
    w = watch.Watch()
    custom_api = client.CustomObjectsApi()

    fn = custom_api.list_namespaced_custom_object

    print("Waiting for %s %s.%s to get created..." % (name, plural, group))
    for event in w.stream(func=fn, namespace=namespace, group=group,
                          version=version, plural=plural,
                          timeout_seconds=timeout):
        if event["type"] != "ADDED":
            continue

        cr = event["object"]
        if cr["metadata"]["name"] != name:
            continue

        # the requested CR got created
        print("%s %s.%s got created." % (name, plural, group))
        w.stop()
        return True

    raise RuntimeError("Timeout reached waiting for CR %s %s.%s" %
                       (name, plural, group))


def succeeded(job):
    """Check if the CR has either a Ready or Succeeded condition"""
    if "status" not in job:
        return False

    if "conditions" not in job["status"]:
        return False

    for condition in job["status"]["conditions"]:
        if "Succeeded" in condition["type"]:
            return condition["status"] == "True"

        if "Ready" in condition["type"]:
            return condition["status"] == "True"

    return False


def wait_to_succeed(name, namespace, group, version, plural, timeout):
    """Wait until the specified TFJob succeeds."""
    w = watch.Watch()
    custom_api = client.CustomObjectsApi()

    cr = {}
    fn = custom_api.list_namespaced_custom_object

    print("Waiting for %s %s.%s to succeed..." % (name, plural, group))
    for event in w.stream(func=fn, namespace=namespace, group=group,
                          version=version, plural=plural,
                          timeout_seconds=timeout):

        cr = event["object"]
        if cr["metadata"]["name"] != name:
            continue

        if event["type"] == "DELETED":
            raise RuntimeError("%s %s.%s was deleted." %
                               (name, plural, group))

        if succeeded(cr):
            w.stop()
            print("%s %s.%s succeeded." % (name, plural, group))
            return

    raise RuntimeError("Timeout reached waiting for %s %s.%s to succeed: %s" %
                       (name, plural, version, cr))

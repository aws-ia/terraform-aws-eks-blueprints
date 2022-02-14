grafana_endpoint               = "<Your Amazon Managaed Grafana Endpoint>"
grafana_api_key                = "<Your Amazon Managed Grafana API Key>"
opensearch_dashboard_user      = "<A username for logging into OpenSearch Dashboard>"
opensearch_dashboard_pw        = "<A password for logging into OpenSearch Dashboard>"                         # Password must be a minimum of eight characters with at least one uppercase, one lowercase, one digit, and one special character
local_computer_ip              = "<IP Address of the computer you are running and testing this example from>" # We configure a route table and security group that allows your computer to access an EC2 instance.
create_iam_service_linked_role = true                                                                         # set this to false if yor account already has the AWSServiceRoleForAmazonElasticsearchService role created

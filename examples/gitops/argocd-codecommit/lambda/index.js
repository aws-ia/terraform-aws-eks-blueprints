/* eslint-env node */ 
const https = require('https'); // eslint-disable-line

/* webhook payload
  {
    "ref": "refs/heads/master",
    "repository": {
      "html_url": "https://git-codecommit.us-west-2.amazonaws.com/v1/repos/eks-blueprints-workloads-cc",
      "default_branch": "master"
    }
  }
*/

exports.handler = async function(event) {
    const eventSourceARNarray = event.Records[0].eventSourceARN.split(':');
    const repoName = eventSourceARNarray[eventSourceARNarray.length - 1];
    const ref = event.Records[0].codecommit.references[0].ref;
    const refArray = ref.split('/');
    const branch = refArray[refArray.length - 1];
    const data = JSON.stringify({
    "ref": ref,
    "repository": {
      "html_url": "https://git-codecommit." + event.Records[0].awsRegion + ".amazonaws.com/v1/repos/" + repoName,
      "default_branch": branch
    }
  });
  console.log(data);

  const options = {
    hostname: event.Records[0].customData,
    path: '/api/webhook',
    method: 'POST',
    port: 443,
    headers: {
      'Content-Type': 'application/json',
      'X-GitHub-Event': 'push',
      'Content-Length': data.length,
    },
  };

  const promise = new Promise(function(resolve, reject) {
    process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = 0;
    const req = https.request(options, (res) => {
        resolve(res.statusCode);
      }).on('error', (e) => {
        reject(Error(e));
      });
      req.write(data);
      req.end();
    });
  return promise;
};
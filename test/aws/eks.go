package aws

import (
	"context"
	"encoding/base64"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/eks"
	apps "k8s.io/api/apps/v1"
	core "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"log"
	"sigs.k8s.io/aws-iam-authenticator/pkg/token"
)

func ListDeploymentItems(k8sclient *kubernetes.Clientset, namespace string) (*apps.DeploymentList, error) {
	deployments, err := k8sclient.AppsV1().Deployments(namespace).List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		log.Fatalf("Error listing the deployments: %v", err)
		return nil, err
	}

	return deployments, nil
}

func GetDeployment(k8sclient *kubernetes.Clientset, deploymentName string, namespace string) (*apps.Deployment, error) {
	deployment, err := k8sclient.AppsV1().Deployments(namespace).Get(context.TODO(), deploymentName, metav1.GetOptions{})
	if err != nil {
		log.Printf("Error getting the deployment: %v", err)
		return nil, err
	}
	return deployment, nil
}

func GetDaemonSet(k8sclient *kubernetes.Clientset, DaemonSetName string, namespace string) (*apps.DaemonSet, error) {
	DaemonSet, err := k8sclient.AppsV1().DaemonSets(namespace).Get(context.TODO(), DaemonSetName, metav1.GetOptions{})
	if err != nil {
		log.Printf("Error getting the DaemonSet: %v", err)
		return nil, err
	}
	return DaemonSet, nil
}

func GetServices(k8sclient *kubernetes.Clientset, ServiceName string, namespace string) (*core.Service, error) {
	service, err := k8sclient.CoreV1().Services(namespace).Get(context.TODO(), ServiceName, metav1.GetOptions{})
	if err != nil {
		log.Printf("Error getting the Services: %v", err)
		return nil, err
	}
	return service, nil
}

func EksDescribeCluster(region string, clusterName string) (*eks.DescribeClusterOutput, error) {
	svc := NewEksSession(region)
	input := &eks.DescribeClusterInput{
		Name: aws.String(clusterName),
	}

	result, err := svc.DescribeCluster(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case eks.ErrCodeResourceNotFoundException:
				fmt.Println(eks.ErrCodeResourceNotFoundException, aerr.Error())
			case eks.ErrCodeClientException:
				fmt.Println(eks.ErrCodeClientException, aerr.Error())
			case eks.ErrCodeServerException:
				fmt.Println(eks.ErrCodeServerException, aerr.Error())
			case eks.ErrCodeServiceUnavailableException:
				fmt.Println(eks.ErrCodeServiceUnavailableException, aerr.Error())
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			fmt.Println(err.Error())
		}
	}
	return result, err
}

func NewEksSession(region string) *eks.EKS {
	mySession := session.Must(session.NewSession(&aws.Config{
		Region: aws.String(region),
	}))
	svc := eks.New(mySession)
	return svc
}

func GetKubernetesClient(cluster *eks.Cluster) (*kubernetes.Clientset, error) {
	log.Printf("%+v", cluster)
	gen, err := token.NewGenerator(true, false)
	if err != nil {
		return nil, err
	}
	opts := &token.GetTokenOptions{
		ClusterID: aws.StringValue(cluster.Name),
	}
	tok, err := gen.GetWithOptions(opts)
	if err != nil {
		return nil, err
	}
	ca, err := base64.StdEncoding.DecodeString(aws.StringValue(cluster.CertificateAuthority.Data))
	if err != nil {
		return nil, err
	}
	k8sclient, err := kubernetes.NewForConfig(
		&rest.Config{
			Host:        aws.StringValue(cluster.Endpoint),
			BearerToken: tok.Token,
			TLSClientConfig: rest.TLSClientConfig{
				CAData: ca,
			},
		},
	)
	if err != nil {
		return nil, err
	}
	return k8sclient, nil
}

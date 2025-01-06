# Improvements

**Given more time, I would improve the following:**
- Automated deployment, such as through Git Actions or CodePipeline, to consistently deploy any changes made on this repository for ease through CI/CD. This would include testing and verification steps such as `terraform validate` and potentially running the Docker container outside of ECS. This could also be achieved with a dedicated IAM Role (in the case of Git Actions, using one that has OpenID Connect Identity Provider set up) so no personal credentials could ever come into play. This seemed like overkill for this particular project right now. As part of this, creating an automated script for simplying the full installation of this repository for local users.
- For the Git repository, with more/other developers, an increase in security/protection that includes protecting the main branch from direct commits and forcing pull requests to be reviewed by a small subset of administrative users, among other considerations. Thus, this was not implemented simply because I am the sole developer on the git repository at this time and that will not change.
- Finding a more elegant solution to building, tagging, and pushing the docker image to ECR. I found a few potential solutions that consumed some extra time and ran into a few bugs along the way. A specific example I tried out was this [Terraform docker_image](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image#build) resource that had some trouble reading my Dockerfile but it seemed promising.
- Investigating other solutions for this that might include Kubernetes (EKS) as well as using different cloud providers like GCP and Azure. My familiarly is primarily with AWS and doing otherwise would have been vastly more time consuming.
- Possibly using DynamoDB locking as part of the backend configuration. As the only developer on this though, it was not necessary.
- A more elegant solution regarding permissions, such using IAM roles and least privilege in originally setting this up. As the main concern for me was getting the AWS services and Terraform configuration working, some security took a back seat, which is not something I would prefer to do. As I am the only developer on this project, security was less of a concern in this instance, but in a real world scenario, locking down IAM Roles, access, and using the principle of least privilege to limit permissions is absolutely paramount. This also goes for the S3 configuration with regards to the bucket policy and KMS.
- Looking at other IAC solutions. I have used CloudFormation extensively as well but I knew I wanted to use Terraform to both be cleaner and easier to implement (as far as I am concerned). CDK would have been interesting to attempt.
- Other approaches to secret management. The AWS Secret Manager certainly worked to help inject the secret environment variable into the container, but it would be nice if the creation of that secret could be safely created via Terraform without exposing the value in the code (though it is ultimately exposed in the webserver anyway). As such, the secret was created separately and manually.
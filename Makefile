# Usage install local requirements
.PHONY: install
install:
	@echo "Installing local requirements...\n"
	pip install --upgrade pip
	pip install -r requirements.txt

.PHONY: pre-commit
pre-commit:
	@echo "Running pre-commit checks...\n"
	pre-commit run --all-files

# Usage: make deploy-cfn-from-local FOLDER=<subfolder-name>
.PHONY: deploy-cfn-from-local
deploy-cfn-from-local:
ifndef FOLDER
	$(error FOLDER is not set. Please specify the subfolder-name using FOLDER=<subfolder-name>)
endif
	@echo "Deploying CloudFormation from ${CURDIR}/src-cloudformation-iac/${FOLDER}\n"
	@chmod +x "${CURDIR}/src-cloudformation-iac/${FOLDER}/scripts/bash/deploy_cfn.sh"
	@# Execute the deploy script and pass the current directory and folder
	@"${CURDIR}/src-cloudformation-iac/${FOLDER}/scripts/bash/deploy_cfn.sh" "${CURDIR}" "${FOLDER}"


# Usage: make cleanup-cfn FOLDER=<subfolder-name> STUDIO_ARN=<studio-arn>
.PHONY: cleanup-cfn
cleanup-cfn:
ifndef FOLDER
	$(error FOLDER is not set. Please specify the subfolder-name using FOLDER=<subfolder-name>)
endif
ifndef STUDIO_ARN
	$(error STUDIO_ARN is not set. Please specify the studio-arn using STUDIO_ARN=<studio-arn>)
endif
	@echo "Cleaning up CloudFormation stacks from ${CURDIR}/src-cloudformation-iac/${FOLDER}\n"
	@chmod +x "${CURDIR}/src-cloudformation-iac/${FOLDER}/scripts/bash/cleanup_cfn.sh"
	@# Execute the cleanup script and pass the current directory, folder, and studio-arn
	@"${CURDIR}/src-cloudformation-iac/${FOLDER}/scripts/bash/cleanup_cfn.sh" "${CURDIR}" "${FOLDER}" "${STUDIO_ARN}"


# Usage: make install-aws-cli
.PHONY: install-aws-cli
install-aws-cli:
	@echo "Installing AWS CLI...\n"
	@chmod +x "${CURDIR}/scripts/bash/aws_utils.sh"
	@"${CURDIR}/scripts/bash/aws_utils.sh" install_aws_cli

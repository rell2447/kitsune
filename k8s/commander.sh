set -e
GREEN='\033[1;32m'
NC='\033[0m' # No Color


function whatsdeployed {
    xdg-open "https://whatsdeployed.io/s-iiX"
}

function deploy {
    REGION=${2}
    REGION_ENV=${3}
    COMMIT_HASH=${4}
    DEPLOY_SECRETS=${5:-NO}

    export KUBECTL_BIN="./regions/${REGION}/kubectl"
    export KUBECONFIG="./regions/${REGION}/kubeconfig"

    if [[ "${DEPLOY_SECRETS}" == "secrets" ]]; then
        echo "Applying secrets";  
        ${KUBECTL_BIN} -n sumo-${REGION_ENV} apply -f "regions/${REGION}/${REGION_ENV}-secrets.yaml"
    else 
        echo "Secrets will *NOT* be applied";
    fi   

    invoke  -f "regions/${REGION}/${REGION_ENV}.yaml" deployments.create-celery --apply --tag full-${COMMIT_HASH}
    invoke  -f "regions/${REGION}/${REGION_ENV}.yaml" rollouts.status-celery
    invoke  -f "regions/${REGION}/${REGION_ENV}.yaml" deployments.create-cron --apply --tag full-${COMMIT_HASH}
    invoke  -f "regions/${REGION}/${REGION_ENV}.yaml" rollouts.status-cron
    invoke  -f "regions/${REGION}/${REGION_ENV}.yaml" deployments.create-web --apply --tag full-${COMMIT_HASH}
    invoke  -f "regions/${REGION}/${REGION_ENV}.yaml" rollouts.status-web
    printf "${GREEN}OK${NC}\n"
}

source venv/bin/activate

$1 $@

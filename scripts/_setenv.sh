PROJ_DIR=$(cd "$BASEDIR/.."; pwd)

SCRIPT_NAME=$(basename "$0")
ENV_NAME=${SCRIPT_NAME%%_*}
if [ "$ENV_NAME" = "$SCRIPT_NAME" ]; then
  ENV_NAME="default"
fi
echo "Loading environment variables from $PROJ_DIR/conf/${ENV_NAME}.sh"
source "$PROJ_DIR/conf/${ENV_NAME}.sh"
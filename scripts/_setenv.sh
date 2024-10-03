PROJ_DIR=$(cd "$BASEDIR/.."; pwd)
# Load environment variables from the configuration file specified as the first argument
if [ -n "$1"  ]; then
  source "$1"
fi
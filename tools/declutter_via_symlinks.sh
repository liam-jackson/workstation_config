#!/bin/zsh

# Initialize
SOURCE_DIR="$HOME"
NO_CLUTTER_DIR="$HOME/Home_NoClutter"
DRY_RUN=false

print_usage() {
  echo "Populate $NO_CLUTTER_DIR with symlinks to subdirectories in $SOURCE_DIR"
  echo "Usage: ./declutter_via_symlinks.sh [OPTIONS]"
  echo "Options:"
  echo "  -i /orig/path   : create symlinks in $NO_CLUTTER_DIR to subdirectories in /orig/path/"
  echo "                      [ Default source for symlink targets is $SOURCE_DIR ]"
  echo "  -d /dest/path   : create symlinks in /dest/path to subdirectories in $SOURCE_DIR"
  echo "                      [ Default destination for symlinks is $NO_CLUTTER_DIR ]"
  echo "  --dry-run       : only show what would happen"
  echo "  -h --help       : print this information and exit"
}

# Parse command-line arguments manually
for arg in "$@"; do
  shift
  case "$arg" in
    "--dry-run")
      DRY_RUN=true
      ;;
    "--help"|"-h")
      print_usage
      exit 0 ;;
    "-i")
      SOURCE_DIR="$1"
      shift ;;
    "-d")
      NO_CLUTTER_DIR="$1"
      shift ;;
    *)
      print_usage
      exit 1 ;;
  esac
done

if [[ "$DRY_RUN" == "true" ]]; then
  echo "---- DRY RUN ----"
  if [[ ! -d $NO_CLUTTER_DIR ]]; then
    echo "Would create directory $NO_CLUTTER_DIR"
  fi
else
  if [[ ! -d $NO_CLUTTER_DIR ]]; then
    mkdir -p $NO_CLUTTER_DIR
  fi
fi

for dir in $SOURCE_DIR/*(/); do
  dir_name=$(basename $dir)
  
  if [[ $dir_name == "$(basename $NO_CLUTTER_DIR)" ]]; then
    continue
  fi
  
  read "response?Do you want to create a symlink to $dir_name in $NO_CLUTTER_DIR? (y/n): "
  
  if [[ $response == 'y' || $response == 'Y' ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "Would create symlink for $dir_name :"
      echo "$dir -> $NO_CLUTTER_DIR/$dir_name"
    else
      echo "Creating symlink for $dir_name :"
      ln -sv $dir $NO_CLUTTER_DIR/$dir_name
    fi
  fi
done

echo "Done!"


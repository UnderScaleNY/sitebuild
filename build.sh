#!/bin/sh
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

# https://stackoverflow.com/questions/3427872/whats-the-difference-between-and-in-bash
if [[ $# != 0 ]]; then
  if [[ $1="bash" || $1="sh" || $1="ash" ]]; then
    exec /bin/sh
  fi
fi


# Default configuration
DEFAULT_SRC_DIR=./site
DEFAULT_DEST_DIR=_site
DEFAULT_BRANCH=master
DEFAULT_SERVE=
DEFAULT_COMPRESS=
# DEFAULT_ALGOLIA_API_KEY=

# Directory where the code is
SRC_DIR=$DEFAULT_SRC_DIR

# Directory where the building site will be put, relatively to CODE_DIR
DEST_DIR=$DEFAULT_DEST_DIR

# Git branch to use, if needeed
BRANCH=$DEFAULT_BRANCH

# Is it to only build the site or also to serve the files through Jekyll (for tests & preview)
SERVE=$DEFAULT_SERVE

# Compress built files in a tar.bz2 file
COMPRESS=$DEFAULT_COMPRESS

# Admin API key for Algolia search engine
# ALGOLIA_API_KEY=$DEFAULT_ALGOLIA_API_KEY


usage()
{
  echo "usage: [-h] [-s <dir>] [-t <dir>] [-b <branch>] [-r]"
  echo "   -s | --source-dir <dir>  Directory where the code is"
  echo "   -t | --target-dir <dir>  Directory where to put built files, relatively to code directory"
  echo "   -b | --branch <branch>   Git branch to use, if needeed"
  # echo "   -k | --algolia-key <key> Admin API key for Algolia search engine"
  echo "   -c | --compress <dir>    Compress built files in site.tar.bz2 to directory"
  echo "   -r | --serve             Serve the files through Jekyll (for tests & preview)"
  echo "   -h | --help              Print usage"
}


while [[ $# != 0 ]]; do
  case $1 in
    -s | --source-dir )
      shift
      SRC_DIR=$1
      ;;
      
    -t | --target-dir )
      shift
      DEST_DIR=$1
      ;;
      
    -b | --branch )
      shift
      BRANCH=$1
      ;;
      
    # -k | --algolia-key )
      # shift
      # ALGOLIA_API_KEY=$1
      # ;;
      
    -c | --compress )
      shift
      COMPRESS=$1
      ;;
      
    -r | --serve )
      SERVE=1
      ;;
      
    -h | --help )
      usage
      exit
      ;;
      
    --test )
      echo -e "\n*** Running tests ***"
      echo -n "- Jekyll version: " && jekyll --version
      echo -e "\n- Current directory: $(pwd)"
      echo -e "\n- Environment variables:" && env
      echo -e "\n- File list: $(ls -alh)"
      exit
      ;;
      
    * )
      echo -e " ! Unrecognized parameters ! \n"
      usage
      exit 1
  esac
  shift
done


if [ ! -d "$SRC_DIR" ]; then
  echo "The directory ./site does not exist --> Downloading code from branch $BRANCH"
  wget -qO- "https://github.com/UnderScaleNY/site/archive/$BRANCH.tar.gz" | tar xz
  mv "site-$BRANCH" "$SRC_DIR"
  echo ""
fi

cd "$SRC_DIR"
mv /home/app/Gemfile .

echo "*** Install NodeJS dependencies ***"
npm --loglevel=error install

echo -e "\n\n*** Build site files with Jekyll ***"
# https://jekyllrb.com/docs/configuration/options/
jekyll build --trace --destination "$DEST_DIR"

echo -e "\n\n*** Download Javascript dependencies ***"
mkdir -p _assets/js/ _vendor/jquery/dist/ _vendor/what-input/dist/

wget -q -O "_assets/js/analytics.js"                         "https://img.stageirites.fr/*(d3d3Lmdvb2dsZS1hbmFseXRpY3MuY29t)*/*(YW5hbHl0aWNzLmpz)*"                                        && echo ""
wget -q -O "_vendor/jquery/dist/jquery-3.5.0.min.js"         "https://code.jquery.com/jquery-3.5.0.min.js"                                          && echo ""
wget -q -O "_vendor/what-input/dist/what-input-5.2.6.min.js" "https://raw.githubusercontent.com/ten1seven/what-input/v5.2.6/dist/what-input.min.js" && echo ""


# Concat Javascript files
echo -e "*** Concatenate & Minify Javascript files ***"
mkdir -p "$DEST_DIR"/js
npm install uglify-js -g
uglifyjs "_vendor/jquery/dist/jquery-3.5.0.min.js" \
         "_vendor/what-input/dist/what-input-5.2.6.min.js" \
         "node_modules/foundation-sites/dist/js/foundation.min.js" \
         _assets/js/*.js > "${DEST_DIR}/js/all.js"

# cat "_vendor/jquery/dist/jquery-3.5.0.min.js" \
    # "_vendor/what-input/dist/what-input-5.2.6.min.js" \
    # "node_modules/foundation-sites/dist/js/foundation.min.js" \
    # _assets/js/*.js > "_assets/js/all.js"

# echo -e "*** Minifi Javascript file ***"
# curl -X POST -s --data-urlencode "${SRC_DIR}/_assets/js/all.js" https://javascript-minifier.com/raw > "${DEST_DIR}/js/all.js"

# Copy special files (to validate some accounts) to build directory
cp validation/* "$DEST_DIR"

# Add revision number to CSS & JS files
old_dir=$(pwd)
cd "$DEST_DIR"
echo -e "\n*** Add revision number to CSS & JS files ***"
for file in js/*.js css/*.css
do
  newfile=${file%.*}_`md5sum $file | cut -d" " -f1`.${file##*.}
  echo " + $file  -->  $newfile"
  mv "$file" "$newfile"
  find ./ -name "*.html" -type f -exec sed -i "s#/$file#/$newfile#g" {} \;
done

# Compress files
if [[ $COMPRESS ]]; then
  echo -e "\n*** Compress static files ***"
  tar -cjf "$COMPRESS"/site.tar.bz2 *
fi

cd $old_dir


# Send data to Algolia
# if [ $ALGOLIA_API_KEY ]; then
  # echo -e "\n*** Send data to Algolia ***"
  # ALGOLIA_API_KEY=$ALGOLIA_API_KEY jekyll algolia
# fi


# Serve files
if [[ $SERVE ]]; then
  echo -e "\n\n*** Serve static files with Jekyll ***"
  exec jekyll serve --trace --skip-initial-build --drafts --unpublished --future --port 8080 --host 0.0.0.0 --destination "$DEST_DIR"
fi

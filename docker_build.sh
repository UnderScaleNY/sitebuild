#/bin/ash

DEST_DIR=../site

# Exit when any command fails
set -e

# git clone https://github.com/UnderScaleNY/site.git . --depth=1
wget -qO- "https://github.com/UnderScaleNY/site/archive/master.tar.gz" | tar xz
cd site-master

npm install

# https://jekyllrb.com/docs/configuration/options/
jekyll build --trace --destination $DEST_DIR

mkdir -p _assets/js/ _vendor/jquery/dist/ _vendor/what-input/dist/

wget -q -O "_assets/js/analytics.js"                         "https://www.google-analytics.com/analytics.js"                                        && echo ""
wget -q -O "_vendor/jquery/dist/jquery-3.5.0.min.js"         "https://code.jquery.com/jquery-3.5.0.min.js"                                          && echo ""
wget -q -O "_vendor/what-input/dist/what-input-5.2.6.min.js" "https://raw.githubusercontent.com/ten1seven/what-input/v5.2.6/dist/what-input.min.js" && echo ""

# Concat Javascript files
mkdir -p $DEST_DIR/js
cat "_vendor/jquery/dist/jquery-3.5.0.min.js" \
    "_vendor/what-input/dist/what-input-5.2.6.min.js" \
    "node_modules/foundation-sites/dist/js/foundation.min.js" \
    _assets/js/*.js > $DEST_DIR/js/all.js

# Copy special files (to validate some accounts) to build directory
cp validation/* $DEST_DIR

# Add revision number to CSS & JS files
cd $DEST_DIR/
for file in js/*.js css/*.css
do
  newfile=${file%.*}_`md5sum $file | cut -d" " -f1`.${file##*.}
  mv "$file" "$newfile"
  find ./ -name "*.html" -type f -exec sed -i "s#/$file#/$newfile#g" {} \;
done


# Serve files (dev)
# ruby -rwebrick -e'WEBrick::HTTPServer.new(:Port => 8080, :DocumentRoot => Dir.pwd).start'
# jekyll serve --trace --host 0.0.0.0 --port 8080 --skip-initial-build

echo -e "\n*** DONE ***\n"
#/bin/ash

DEST_DIR=../site

# git clone https://github.com/UnderScaleNY/site.git . --depth=1
wget -qO- https://github.com/UnderScaleNY/site/archive/master.tar.gz | tar xz
cd site-master

# https://jekyllrb.com/docs/configuration/options/
jekyll build --trace --destination $DEST_DIR

wget "https://www.google-analytics.com/analytics_debug.js" -O _assets/js/analytics.js

# Concat Javascript files
mkdir -p $DEST_DIR/js
cat "node_modules/jquery/dist/jquery.min.js" \
    "node_modules/what-input/dist/what-input.min.js" \
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
  # sed -i "s#/$file#/$newfile#g" index.html
done


# Serve files (dev)
jekyll serve --trace --host 172.17.0.2 --port 4000 --skip-initial-build

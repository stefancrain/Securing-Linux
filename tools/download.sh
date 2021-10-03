#!/bin/bash
# download ubuntu
# check for validity
# create log of it's metadata version

REPOSITORY_FOLDER="./isos"
URL="http://releases.ubuntu.com/releases/"
RELEASE="${1:-focal}" # bionic, eoan
ARCH="amd64" # armhf

echo "-------------------------------------------------------------------------"
echo "Creating list of [${ARCH}] resourcs from ${URL}${RELEASE}"
mkdir -p "${REPOSITORY_FOLDER}/${RELEASE}"|| exit 5
cd "${REPOSITORY_FOLDER}/${RELEASE}" || exit 5

# form curated resources from ubuntu repo
curl -s -L ${URL}"${RELEASE}/" | \
  grep "\[   \]" | \
  sed -n 's/.*href="\([^"]*\).*/\1/p' | \
  sed \
    -e "s#^#${URL}${RELEASE}/#g" \
    -e "s#.*metalink.*\$##g" \
    -e "s#.*MD5.*\$##g" \
    -e "s#.*MD5.*\$##g" \
    -e "s#.*\.torrent\$##g" \
    -e "s#.*\.jigdo\$##g" \
    -e "s#.*\.list\$##g" \
    -e "s#.*\.manifest\$##g" \
    -e "s#.*\.template\$##g" \
    -e "s#.*\.torrent\$##g" \
    -e "s#.*\.zsync\$##g" \
    -e "s# ##g" | \
  grep -e "${ARCH}" -e ".*SUMS" | \
  sort > download_list.txt || exit 5

echo "-------------------------------------------------------------------------"
echo "Downloading $(wc -l download_list.txt|awk '{print $1}') files with aria2"
aria2c \
  --quiet \
  --continue=true \
  --input-file=download_list.txt \
  --allow-overwrite=true \
  --max-connection-per-server=16 \
  --log=aria2.log || exit 5

echo "-------------------------------------------------------------------------"
echo "Installing ubuntu gpg signatures"
gpg \
  --keyid-format long \
  --keyserver hkp://keyserver.ubuntu.com \
  --recv-keys 0x46181433FBB75451 0xD94AA3F0EFE21092 || exit 5
gpg \
  --keyid-format long \
  --list-keys \
  --with-fingerprint 0x46181433FBB75451 0xD94AA3F0EFE21092 || exit 5

echo "-------------------------------------------------------------------------"
echo "Validating checksum and files"
# CHECKS=('SHA1SUMS' 'SHA256SUMS')
CHECKS=('SHA256SUMS')
for CHECK in "${CHECKS[@]}"
do
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "Testing GPG ${CHECK}"
  gpg \
    --quiet \
    --no-tty \
    --verify \
    "${CHECK}.gpg" "${CHECK}" || exit 5
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "Testing SHA ${CHECK}"
  shasum \
    --warn \
    --check \
    --ignore-missing \
    "${CHECK}" || exit 5
done

echo "-------------------------------------------------------------------------"
for FILE in *.iso; do
  echo "File ready : ${REPOSITORY_FOLDER}/${RELEASE}/${FILE}"
done

# In case of custom $PATH where our swiftlint might live
if [ -e "${HOME}/.bash_profile" ]; then
	source "${HOME}/.bash_profile"
fi

if [ -e "${HOME}/.bashrc" ]; then
	source "${HOME}/.bashrc"
fi

if which swiftlint >/dev/null; then
	swiftlint
else
	echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi

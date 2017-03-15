# clrconvert
Tool for generation UIColor extensions from .clr files

## Usage
1. Add clrconvert as target dependency
2. Add build rule for "*.clr"

	"$BUILD_DIR"/"$CONFIGURATION"/clrconvert "$INPUT_FILE_PATH" "$DERIVED_SOURCES_DIR"

Output Files:

	$(DERIVED_SOURCES_DIR)/UIColor+CS.swift
	$(DERIVED_SOURCES_DIR)/UIColor+$(INPUT_FILE_BASE).swift

![buildRule](https://github.com/mrdepth/clrconvert/blob/master/buildRule.png)

3. Add .clr file to the "Build Phases->Compile Sources"
4. In the application:didFinishLaunchingWithOptions activate color scheme

	CSScheme.currentScheme = CSScheme.Dark

5. Refer to colors by name

	view.backgroundColor = UIColor.colorName

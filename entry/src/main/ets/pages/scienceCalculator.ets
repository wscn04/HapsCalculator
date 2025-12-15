import router from '@ohos.router';

// 定义按钮点击回调类型
type ButtonPressCallback = (label: string) => void;

// --- 复用之前的按钮组件
@Component
struct ScientificButton {
  label: string = '0';
  btnBackgroundColor: Color = 0xFF333333;
  fontColor: Color = Color.White;
  onPress: ButtonPressCallback = (label: string) => {};

  build() {
    Button(this.label)
      .width('100%')
      .height('100%')
      .type(ButtonType.Normal)
      .fontSize(28)
      .fontColor(this.fontColor)
      .borderRadius(100)

      // 样式与动画
      .stateStyles({
        normal: { .backgroundColor(this.btnBackgroundColor) },
        pressed: { .backgroundColor(this.getPressedColor()) }
      })
      .animation({ duration: 200, curve: Curve.EaseOut })
      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.95 })

      .onClick(() => {
        this.onPress(this.label);
      })
  }

  getPressedColor(): ResourceColor {
    if (this.btnBackgroundColor == 0xFFFF9500) return 0xFFCC7700;
    if (this.btnBackgroundColor == 0xFFAFAFAF) return 0xFF888888;
    if (this.btnBackgroundColor == 0xFF007AFF) return 0xFF0056B3; // 蓝色按下变深蓝
    return 0xFF1A1A1A;
  }
}

@Entry
@Component
struct ScienceCalculator {
  @State displayValue: string = '0';

  // --- 科学计算器布局 (5 列) ---
  private buttonLayout: string[][] = [
    ['🧐', '(', ')', 'C', 'Del'],
    ['sin', 'cos', 'tan', 'π', '÷'],
    ['7', '8', '9', '√', '×'],
    ['4', '5', '6', '^', '-'],
    ['1', '2', '3', 'e', '+'],
    ['0', '.', 'log', 'ln', '=']
  ];

  // --- 按钮逻辑处理 ---
  onButtonPress(label: string) {
    if (label === '🧐') {
      // 🔙 返回普通计算器
      router.back();
    } else if (label === 'C') {
      this.displayValue = '0';
    } else if (label === 'Del') {
      this.handleDelete();
    } else if (label === '=') {
      // 暂时只做简单的模拟
      this.displayValue = '🤯🤯🤯';
    } else {
      this.handleInput(label);
    }
  }

  // 输入处理
  handleInput(label: string) {
    if (this.displayValue === '0' || this.displayValue === '🤯🤯🤯') {
      this.displayValue = label;
    } else {
      this.displayValue += label;
    }
  }

  // 删除处理
  handleDelete() {
    if (this.displayValue.length > 1) {
      this.displayValue = this.displayValue.slice(0, -1);
    } else {
      this.displayValue = '0';
    }
  }

  build() {
    Column() {
      // 1. 标题栏 (显示 "科学模式")
      Text('科学模式')
        .width('100%')
        .padding({ top: 10, left: 20 })
        .textAlign(TextAlign.Start)
        .fontSize(16)
        .fontColor(Color.Gray)

      // 2. 结果显示区域
      Column() {
        Text(this.displayValue)
          .width('100%')
          .padding({ right: 20 })
          .textAlign(TextAlign.End)
          .fontSize(60)
          .fontColor(Color.White)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
      .padding({ bottom: 20 })

      // 3. 按钮区域
      Column() {
        ForEach(this.buttonLayout, (row: string[]) => {
          Row() {
            ForEach(row, (label: string) => {
              Column() {
                ScientificButton({
                  label: label,
                  btnBackgroundColor: this.getButtonColor(label),
                  fontColor: this.getFontColor(label),
                  onPress: (label: string): void => this.onButtonPress(label),
                })
              }
              .layoutWeight(1) // 所有按钮等宽
            }, (label: string) => label)
          }
          .width('100%')
          .aspectRatio(5.5) // 调整行高，稍微扁一点以便放下更多行
          .padding({ top: 3, bottom: 3 })
        }, (row: string[]) => row[0])
      }
      .width('100%')
      .padding(10)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }

  // --- 颜色配置 ---
  getButtonColor(label: string): Color {
    if (label === 'Back') return 0xFF007AFF; // 返回键：蓝色
    if (['C', 'Del'].includes(label)) return 0xFFAFAFAF; // 功能键：浅灰
    if (['+', '-', '×', '÷', '=', '(', ')'].includes(label)) return 0xFFFF9500; // 运算符：橙色
    if (['sin', 'cos', 'tan', 'log', 'ln', 'π', 'e', '√', '^'].includes(label)) return 0xFF222222; // 科学函数：更深的灰色
    return 0xFF333333; // 数字：深灰
  }

  getFontColor(label: string): Color {
    if (['C', 'Del'].includes(label)) return Color.Black;
    return Color.White;
  }
}
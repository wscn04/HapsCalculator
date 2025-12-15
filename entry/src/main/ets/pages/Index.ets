
import router from '@ohos.router'; //
type ButtonPressCallback = (label: string) => void;

@Component
struct CalculatorButton {
  label: string = '0';
  btnBackgroundColor: Color = 0xFFD2D2D2;
  fontColor: Color = Color.Black;
  onPress: ButtonPressCallback = (label: string) => {};

  build() {
    Button(this.label)
      .width('100%')
      .height('100%')
      .fontSize(40)
      .fontColor(this.fontColor)
      .borderRadius(100)
      .margin(5)


      .stateStyles({
        // 正常状态 (Normal)
        normal: {
          .backgroundColor(this.btnBackgroundColor)
        },
        // 按下状态 (Pressed) - 变为更深的颜色
        pressed: {
          .backgroundColor(this.getPressedColor())
        }
      })


      .animation({
        duration: 200, // 动画持续 200ms
        curve: Curve.EaseOut // 使用减速曲线，模拟物理扩散感
      })


      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.95 })

      .onClick(() => {
        this.onPress(this.label);
      })
  }

  // 🎨 辅助函数：计算“按下”时的深色颜色
  getPressedColor(): ResourceColor {
    // 这里手动定义三种按钮对应的“深色版”
    if (this.btnBackgroundColor == 0xFFFF9500) {
      return 0xFFCC7700; //
    } else if (this.btnBackgroundColor == 0xFFAFAFAF) {
      return 0xFF888888; //
    } else {
      return 0xFF1A1A1A; //
    }
  }
}

@Entry
@Component
struct CalculatorPage {
  // --- 状态变量 ---
  @State displayValue: string = '0'; // 显示屏上的数值
  @State firstOperand: number | null = null; // 存储第一个操作数
  @State operator: string | null = null; // 存储当前的运算符 (例如 +)
  @State isWaitingForSecondOperand: boolean = false; // 标记是否正在等待输入第二个数字

  private buttonLayout: string[][] = [
    ['🤓','AC', '+/-', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '.', '=']
  ];
  // 新增：处理页面跳转的函数
  handleNavigate() {
    try {
      router.pushUrl({
        url: 'pages/scienceCalculator'
      }, router.RouterMode.Single);

      console.info('[Router] Successfully attempted navigation to Science Calculator.');

    }
    catch(err) {
      const error = err as Error;
      console.error(`[Router] Navigation failed: ${error.message}`);
    }
  }
  // --- 核心逻辑处理 ---
  onButtonPress(label: string) {
    console.info(`[Calculator] 用户点击了按钮: ${label}`);
    // 增加跳转逻辑
    if (label === '🤓') {
      this.handleNavigate();
      return;
    }
    if (label === 'AC') {
      this.handleClear();
    } else if (label === '+/-') {
      this.handleSign();
    } else if (label === '%') {
      this.handlePercent();
    } else if (['+', '-', '×', '÷'].includes(label)) {
      this.handleOperator(label);
    } else if (label === '=') {
      this.handleEqual();
    } else {
      // 剩下的都是数字或小数点
      this.handleNumber(label);
    }
  }

  // 1. 处理数字和小数点
  handleNumber(label: string) {
    if (this.isWaitingForSecondOperand) {
      // 如果按下了运算符，正在等待第二个数字，那么新输入的数字应该覆盖显示屏
      this.displayValue = label === '.' ? '0.' : label;
      this.isWaitingForSecondOperand = false;
    } else {
      // 否则是追加模式
      if (label === '.') {
        if (!this.displayValue.includes('.')) {
          this.displayValue += '.';
        }
      } else {
        // 如果当前是0且不是小数，直接替换，否则追加
        if (this.displayValue === '0') {
          this.displayValue = label;
        } else {
          // 限制长度防止溢出
          if(this.displayValue.length < 15) {
            this.displayValue += label;
          }
        }
      }
    }
  }

  // 2. 处理运算符 (+ - × ÷)
  handleOperator(nextOperator: string) {
    const inputValue = parseFloat(this.displayValue);

    // 如果已经有第一个数和运算符，且不是刚刚按下运算符（连续运算逻辑，如 1+2+...）
    if (this.firstOperand !== null && this.operator && !this.isWaitingForSecondOperand) {
      const result = this.calculate(this.firstOperand, inputValue, this.operator);
      this.displayValue = String(result);
      this.firstOperand = result; // 将结果作为下一次运算的第一个数
    } else {
      // 第一次按下运算符
      this.firstOperand = inputValue;
    }

    this.operator = nextOperator;
    this.isWaitingForSecondOperand = true; // 准备接收下一个数字
  }

  // 3. 处理等号 (=)
  handleEqual() {
    if (this.operator && this.firstOperand !== null) {
      const inputValue = parseFloat(this.displayValue);
      const result = this.calculate(this.firstOperand, inputValue, this.operator);

      this.displayValue = String(result);
      // 运算结束，重置状态，但保留显示结果
      this.firstOperand = null;
      this.operator = null;
      this.isWaitingForSecondOperand = true; //以此标记运算结束，下次输入数字会直接覆盖
    }
  }

  // 4. 执行具体运算
  calculate(first: number, second: number, op: string): number {
    console.info(`[Calculator] 开始计算: ${first} ${op} ${second}`);
    let result = 0;
    switch (op) {
      case '+': result = first + second; break;
      case '-': result = first - second; break;
      case '×': result = first * second; break;
      case '÷': result = second === 0 ? 0 : first / second; break; // 简单防除以0
    }
    // 处理浮点数精度问题 (简单的处理方式)
    console.info(`[Calculator] 计算结果: ${result}`);
    return parseFloat(result.toPrecision(12));
  }

  // 5. 处理清零 (AC)
  handleClear() {
    this.displayValue = '0';
    this.firstOperand = null;
    this.operator = null;
    this.isWaitingForSecondOperand = false;
  }

  // 6. 处理正负号 (+/-)
  handleSign() {
    const value = parseFloat(this.displayValue);
    this.displayValue = String(value * -1);
  }

  // 7. 处理百分比 (%)
  handlePercent() {
    const value = parseFloat(this.displayValue);
    this.displayValue = String(value / 100);
  }

  // --- 界面布局 ---
  build() {
    Column() {
      // 结果显示区域
      Column() {
        Text(this.displayValue)
          .width('100%')
          .padding({ right: 30 })
          .textAlign(TextAlign.End)
          .fontSize(80)
          .fontColor(Color.White)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)

      // 按钮区域
      Column() {
        ForEach(this.buttonLayout, (row: string[]) => {
          Row() {
            ForEach(row, (label: string) => {
              Column() {
                CalculatorButton({
                  label: label,
                  btnBackgroundColor: this.getButtonColor(label),
                  fontColor: this.getFontColor(label),
                  //onPress: this.onButtonPress.bind(this),
                  // 正确的 ArkTS 写法 (箭头函数)
                  // ✅ 正确写法：显式声明返回类型为 void
                  onPress: (label: string): void => this.onButtonPress(label),
                })
              }
              .layoutWeight(this.buttonLayout.indexOf(row) === 0 ? 1 : (label === '0' ? 2 : 1))
            }, (label: string) => label)
          }
          .width('100%')
          .aspectRatio(this.buttonLayout.indexOf(row) === 0 ? 5 : 4)
          .padding({ top: 5, bottom: 5 })
        }, (row: string[]) => row[0])
      }
      .width('100%')
      .padding(10)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }

  getButtonColor(label: string): Color {
    if (label === '🤓') {
      return 0xFF007AFF;
    } else if (['+', '-', '×', '÷', '='].includes(label)) {
      return 0xFFFF9500;
    } else if (['AC', '+/-', '%'].includes(label)) {
      return 0xFFAFAFAF;
    } else {
      return 0xFF333333;
    }
  }

  getFontColor(label: string): Color {
    if (['🤓','AC', '+/-', '%'].includes(label)) {
      return Color.Black;
    }
    return Color.White;
  }
}
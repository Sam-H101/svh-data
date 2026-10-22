package survarium.messages
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import scaleform.clik.controls.Button;
   import scaleform.clik.events.ButtonEvent;
   import survarium.controls.Message;
   import survarium.controls.NumericStepperExchange;
   import survarium.controls.PlayerInfo;
   import survarium.data.LocalizationData;
   import survarium.managers.GameInterface;
   
   public class MessageMoneyExchange extends MessageAccept
   {
      // An exchange_premium_money amount with this bit set asks the server to
      // buy (amount & 0xFFFF) gold with silver at the 0x8D rate. The stock
      // window never sends more than 9999.
      public static const BUY_GOLD_FLAG:uint = 0x40000000;
      
      private static const MAX_GOLD:int = 9999;
      
      // Layout on bg (popups_bg_2) frame 2, 600 x 350 px (frame 1: 600 x 240).
      // Buttons are 140 x 34, the stepper 268 x 40, the title 40 px high.
      private static const ACCEPT_X:Number = 230;
      
      private static const ACCEPT_Y:Number = 154;
      
      private static const CAPTION_Y:Number = 196;
      
      private static const ROW2_Y:Number = 240;
      
      private static const BUTTONS_Y:Number = 296;
      
      public var textFieldLabel:TextField;
      
      public var exchangeStepper:NumericStepperExchange;
      
      private var _callBack:String = "";
      
      private var _useTotal:Boolean = false;
      
      private var _buyStepper:NumericStepperExchange;
      
      private var _buyButton:Button;
      
      public function MessageMoneyExchange()
      {
         super();
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         this._useTotal = _data.useTotal;
         this.exchangeStepper.setExchangeTargetType(_data.target);
         this.exchangeStepper.setExchangeMoneyType(_data.source);
         this.exchangeStepper.setExchangeMoneyFactor(_data.factor);
         var value:int = int(_data.amount);
         var max:int = Math.min(9999,value);
         if(this._useTotal)
         {
            max = Math.min(9999,int(value / _data.factor));
         }
         var isMoneyEnougth:Boolean = max >= _data.stepSize;
         this.exchangeStepper.minimum = isMoneyEnougth ? Number(_data.stepSize) : 0;
         this.exchangeStepper.value = this.exchangeStepper.minimum;
         this.exchangeStepper.maximum = max;
         this.exchangeStepper.editable = true;
         this.exchangeStepper.stepSize = _data.stepSize;
         this.exchangeStepper.enabled = isMoneyEnougth;
         btnAccept.label = LocalizationData.getName("exchange_button").toUpperCase();
         btnAccept.enabled = isMoneyEnougth;
         this.textFieldLabel.text = _data.label;
         this._callBack = _data.callBack;
         this.addBuyGoldRow();
      }
      
      private function addBuyGoldRow() : void
      {
         var rate:uint = PlayerInfo.premiumExchangeRate;
         var bg:MovieClip = getChildByName("bg") as MovieClip;
         if(this._useTotal || this._callBack != "exchange_premium_money" || rate == 0 || bg == null || bg.totalFrames < 2)
         {
            return;
         }
         bg.gotoAndStop(2);
         var rowY:Number = ROW2_Y;
         var caption:TextField = new TextField();
         caption.embedFonts = this.textFieldLabel.embedFonts;
         caption.defaultTextFormat = this.textFieldLabel.getTextFormat();
         caption.selectable = false;
         caption.mouseEnabled = false;
         caption.x = this.textFieldLabel.x;
         caption.y = CAPTION_Y;
         caption.width = this.textFieldLabel.width;
         caption.height = this.textFieldLabel.height;
         caption.text = LocalizationData.getName("online_store");
         addChild(caption);
         var stepper:NumericStepperExchange = new OptionStepperBtnExchangePop();
         stepper.x = this.exchangeStepper.x;
         stepper.y = rowY;
         stepper.setExchangeMoneyType(2);
         stepper.setExchangeTargetType(1);
         stepper.setExchangeMoneyFactor(rate);
         var max:int = Math.min(MAX_GOLD,int(PlayerInfo.genericMoney / rate));
         var canBuy:Boolean = max >= 1;
         stepper.maximum = Math.max(max,0);
         stepper.minimum = canBuy ? 1 : 0;
         stepper.value = stepper.minimum;
         stepper.editable = true;
         stepper.stepSize = 1;
         stepper.enabled = canBuy;
         addChild(stepper);
         this._buyStepper = stepper;
         var button:Button = new SrvButtonRedShared();
         button.x = btnAccept.x;
         button.y = BUTTONS_Y;
         button.label = LocalizationData.getName("buy").toUpperCase();
         button.enabled = canBuy;
         button.addEventListener(ButtonEvent.CLICK,this.onBuyGold,false,0,true);
         addChild(button);
         this._buyButton = button;
         btnCancel.y = BUTTONS_Y;
         btnAccept.x = ACCEPT_X;
         btnAccept.y = ACCEPT_Y;
      }
      
      private function onBuyGold(event:ButtonEvent = null) : void
      {
         if(!this._buyButton.enabled)
         {
            return;
         }
         var gold:uint = uint(this._buyStepper.value);
         Message.onClick(_id);
         if(gold > 0)
         {
            GameInterface.call(this._callBack,uint(BUY_GOLD_FLAG | gold));
         }
      }
      
      override protected function onMessageAccept(event:ButtonEvent = null) : void
      {
         var valueToExchange:uint = 0;
         super.onMessageAccept(event);
         if(btnAccept.enabled)
         {
            valueToExchange = this._useTotal ? uint(this.exchangeStepper.value * this.exchangeStepper.getExchangeMoneyFactor()) : uint(this.exchangeStepper.value);
            GameInterface.call(this._callBack,valueToExchange);
         }
      }
   }
}

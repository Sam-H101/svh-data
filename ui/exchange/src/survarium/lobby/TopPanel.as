package survarium.lobby
{
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.getDefinitionByName;
   import scaleform.clik.constants.InvalidationType;
   import scaleform.clik.controls.Button;
   import scaleform.clik.controls.ScrollingList;
   import scaleform.clik.controls.StatusIndicator;
   import scaleform.clik.controls.ToolTip;
   import scaleform.clik.core.UIComponent;
   import scaleform.clik.events.ButtonEvent;
   import scaleform.clik.events.ListEvent;
   import scaleform.gfx.TextFieldEx;
   import survarium.Util;
   import survarium.buttons.ButtonIcon;
   import survarium.buttons.ButtonLabeled;
   import survarium.constants.Events;
   import survarium.controls.Message;
   import survarium.controls.PlayerInfo;
   import survarium.controls.TopMenu;
   import survarium.controls.UIPopUp;
   import survarium.data.LocalizationData;
   import survarium.events.GameEvent;
   import survarium.managers.GameInterface;
   import survarium.messages.MessageEnterName;
   
   public class TopPanel extends UIComponent
   {
      
      public var changeNameDelay:int;
      
      public var changeNameFailedDelay:int;
      
      public var goldDiscount:int;
      
      public var goldDiscountTime:int;
      
      public var panelPlayer:MovieClip;
      
      public var bgSmall:MovieClip;
      
      public var bgSmall2:MovieClip;
      
      public var buttons:MovieClip;
      
      public var btnCogs:ButtonLabeled;
      
      public var btnLeagueCurrency:ButtonLabeled;
      
      public var btnPremiumMoney:Button;
      
      public var btnRegularMoney:Button;
      
      public var btnKnowledgeBase:ButtonIcon;
      
      public var btnSettings:ButtonIcon;
      
      public var btnChangeName:ButtonIcon;
      
      public var btnLeague:ButtonIcon;
      
      public var btnShop:ButtonIcon;
      
      public var btnClan:ButtonIcon;
      
      public var btnRewards:ButtonIcon;
      
      public var background:MovieClip;
      
      public var txGeneric:TextField;
      
      public var txPremium:TextField;
      
      public var faction_lvl:TextField;
      
      public var left_corner:MovieClip;
      
      public var mid_back:MovieClip;
      
      public var factionsProgress:MovieClip;
      
      public var changeNameCostPremium:int;
      
      public var topBar:ScrollingList;
      
      private var _topMenu:MovieClip;
      
      private var _changeNicknameMessage:MessageEnterName;
      
      private var _show_query:Boolean = true;
      
      private var _openFactions:Boolean = false;
      
      private var _playerLevel:int = 0;
      
      private var _progressText:String = "";
      
      protected var _clanAbb:String = "";
      
      protected var _clanState:uint = 0;
      
      private var _dynamicRect:BitmapData = new top_panel_bg_tile();
      
      private var _notesVisible:Boolean = false;
      
      private var _notesMessage:* = null;
      
      public function TopPanel()
      {
         super();
         this.topBar = this.buttons.topBar;
         this.panelPlayer = this.buttons.panelPlayer;
         this.bgSmall2 = this.buttons.bgSmall2;
         this.btnLeague = this.bgSmall2.btnLeague;
         this.btnClan = this.bgSmall2.btnClan;
         this.btnRewards = this.bgSmall2.btnRewards;
         this.btnCogs = this.panelPlayer.btnCogs;
         this.btnRegularMoney = this.panelPlayer.btnRegularMoney;
         this.btnPremiumMoney = this.panelPlayer.btnPremiumMoney;
         this.btnCogs.visible = false;
         this.btnLeagueCurrency = this.panelPlayer.btnLeagueCurrency;
         this.btnLeagueCurrency.visible = false;
         this.txGeneric = this.panelPlayer.btnRegularMoney.content.txMoney;
         this.txPremium = this.panelPlayer.btnPremiumMoney.content.txMoney;
         this.txPremium.mouseEnabled = this.btnPremiumMoney.mouseEnabled = false;
         this.txGeneric.mouseEnabled = this.btnRegularMoney.mouseEnabled = false;
         this.btnKnowledgeBase = this.bgSmall.btnKnowledgeBase;
         this.btnSettings = this.bgSmall.btnSettings;
         this.btnChangeName = this.bgSmall2.btnChangeName;
         this.btnShop = this.bgSmall2.btnShop;
         this.btnShop.iconIndex = 1;
         this.btnSettings.iconIndex = 4;
         this.btnLeague.iconIndex = 5;
         this.btnChangeName.iconIndex = 2;
         this.btnKnowledgeBase.iconIndex = 3;
         this.btnChangeName.visible = false;
         this.btnChangeName.addEventListener(ButtonEvent.CLICK,this.showChangeNameMessage);
         this.factionsProgress = this.panelPlayer.factionsProgress;
         this.factionsProgress.addEventListener(ButtonEvent.CLICK,this.handleFactionClick);
         (this.factionsProgress as Button).tooltipRendererName = "SrvTextHintRenderer";
         this.btnClan.iconIndex = 1;
         this.btnRewards.iconIndex = 6;
         this.btnClan.visible = true;
         this.btnRewards.visible = true;
      }
      
      private function showFactionSelector() : void
      {
         (this._topMenu as TopMenu).deselectMenu();
         (this._topMenu as TopMenu).deselect();
         (this.factionsProgress as Button).selected = true;
         dispatchEvent(new Event(Events.SHOW_FACTION_SELECTOR,true));
      }
      
      private function handleFactionClick(e:ButtonEvent) : void
      {
         trace("handleFactionClick");
         if(Boolean(this._changeNicknameMessage) && Boolean(this._changeNicknameMessage.parent))
         {
            this._openFactions = true;
            this.closeRename(e);
            return;
         }
         this.showFactionSelector();
      }
      
      public function showFaceLoadingIndicator(bool:Boolean) : void
      {
         if(this._changeNicknameMessage)
         {
            this._changeNicknameMessage.showLoadingIndicator(bool);
         }
      }
      
      public function handleNicknameValidation(result:Boolean, name:String = null, message:String = null, suggestedNames:Array = null) : void
      {
         if(this._changeNicknameMessage)
         {
            this._changeNicknameMessage.handleNicknameValidation(result,name,message,suggestedNames);
         }
      }
      
      private function openChangeName(obj:Object) : void
      {
         var tutorial:Boolean = false;
         var ref:Class = null;
         var e:ButtonEvent = obj.e;
         tutorial = Boolean(obj.tutorial);
         if(MainScene.activePop)
         {
            MainScene.ignoreRemoved = true;
            MainScene.activePop.closeWindow();
         }
         this._topMenu.deselectMenu();
         var voucherId:uint = PlayerInfo.getVoucherId(0);
         var messageData:Object = {
            "layout":{"offsetH":200},
            "face":PlayerInfo.face,
            "nickname":PlayerInfo.nickname,
            "premiumCost":this.changeNameCostPremium,
            "vouchersCost":1,
            "voucherId":voucherId,
            "changeNameFailedDelay":6000,
            "changeNameDelay":1000,
            "tutorial":tutorial
         };
         this.btnChangeName.selected = true;
         if(!this._changeNicknameMessage)
         {
            ref = getDefinitionByName("SrvChaneName") as Class;
            this._changeNicknameMessage = new ref();
            (this._topMenu as TopMenu).setFaceSelector(this._changeNicknameMessage);
         }
         this._changeNicknameMessage.autoClose = false;
         this._changeNicknameMessage.closable = !tutorial;
         MainScene.activePop = this._changeNicknameMessage;
         if(!this._changeNicknameMessage.parent)
         {
            this._changeNicknameMessage.x = MainScene.stageWidth - this._changeNicknameMessage.width - 10;
            this._changeNicknameMessage.y = (MainScene.stageHeight - this._changeNicknameMessage.height) / 2;
            if(tutorial)
            {
               MainScene.stage.addChild(this._changeNicknameMessage);
            }
            else
            {
               addChild(this._changeNicknameMessage);
            }
         }
         MainScene.activePop = this._changeNicknameMessage;
         if(tutorial)
         {
            messageData.nickname = "";
         }
         this._changeNicknameMessage.setData(messageData);
         this._changeNicknameMessage.addEventListener(Event.REMOVED_FROM_STAGE,this.onRenameClosed);
         (this._changeNicknameMessage as UIPopUp).activate(true,true);
         (this._topMenu as TopMenu).deselect();
         dispatchEvent(new Event(Events.HIDE_WINDOW,true));
         if(tutorial)
         {
            dispatchEvent(new Event(Events.CLOSE_WINDOWS,true));
         }
         else
         {
            this._topMenu.addEventListener(Event.ACTIVATE,this.closeRename);
         }
      }
      
      public function showChangeNameMessage(e:ButtonEvent = null, tutorial:Boolean = false) : void
      {
         if(Boolean(this._changeNicknameMessage) && Boolean(this._changeNicknameMessage.parent))
         {
            return;
         }
         if(this._topMenu as TopMenu)
         {
            if((this._topMenu as TopMenu).askCurrentUIHasChanges(this.openChangeName,null,{
               "e":e,
               "tutorial":tutorial
            }))
            {
               return;
            }
         }
         this.openChangeName({
            "e":e,
            "tutorial":tutorial
         });
      }
      
      private function closeRename(e:Event = null) : void
      {
         trace("closeRename ",this._changeNicknameMessage,this._changeNicknameMessage.parent,e);
         trace("_changeNicknameMessage.visible ",this._changeNicknameMessage.visible);
         if(Boolean(this._changeNicknameMessage) && Boolean(this._changeNicknameMessage.parent) && Boolean(e))
         {
            this._changeNicknameMessage.closeWindow();
         }
      }
      
      private function onRenameClosed(e:Event) : void
      {
         this._topMenu.tabPage.removeEventListener(ListEvent.INDEX_CHANGE,this.closeRename);
         this._changeNicknameMessage.removeEventListener(Event.REMOVED_FROM_STAGE,this.onRenameClosed);
         this._topMenu.removeEventListener(Event.ACTIVATE,this.closeRename);
         var data:Object = this._changeNicknameMessage.getData();
         if(Boolean(data) && Boolean(data.tutorial))
         {
            dispatchEvent(new GameEvent(Events.SHOW_WINDOWS,null,true));
         }
         this.btnChangeName.selected = false;
         if(MainScene.ignoreRemoved)
         {
            MainScene.ignoreRemoved = false;
            return;
         }
         dispatchEvent(new Event(Events.ENTER_NAME_REMOVED,true));
         var menu:TopMenu = this._topMenu as TopMenu;
         if(menu == null || this._topMenu == null)
         {
            return;
         }
         trace("_openFactions",this._openFactions);
         trace("_changeNicknameMessage._acceptClosed",this._changeNicknameMessage._acceptClosed);
         if(this._openFactions)
         {
            trace("showFactionSelector 1");
            this._openFactions = false;
            this.showFactionSelector();
         }
         else
         {
            menu.selectTab(TopMenu.MAIN_INDEX);
         }
      }
      
      public function set player_level(value:uint) : void
      {
         this._playerLevel = value;
         this.updatePlayerInfo();
      }
      
      public function updatePlayerInfo() : void
      {
         this.panelPlayer.txLevel.text = this._playerLevel.toString();
         this.panelPlayer.txLevel_small.text = LocalizationData.getName("lvl");
      }
      
      public function set progress_hint(value:String) : void
      {
         this._progressText = value;
         this.panelPlayer.playerInfo.textFieldProgress.text = value;
         this.panelPlayer.playerInfo.textFieldProgress.visible = false;
         (this.panelPlayer.playerInfo.hintButton as ToolTip).tipData = {"name":value};
         this.updatePlayerInfo();
      }
      
      public function set player_progress(value:uint) : void
      {
         this.panelPlayer.playerInfo.progress_indicator.maximum = 100;
         this.panelPlayer.playerInfo.progress_indicator.value = value;
      }
      
      public function setNewInventoryItems(value:uint) : void
      {
         this.topBar.dataProvider[2].shine = value > 0 && this.topBar.selectedIndex != 2;
         this.topBar.dataProvider.invalidate();
      }
      
      public function setNewItems(value:uint) : void
      {
      }
      
      public function setFreePoints(value:uint) : void
      {
      }
      
      public function setTopMenu(value:MovieClip) : void
      {
         addChild(value);
         if(!this.topBar)
         {
            this.topBar = this.buttons.topBar;
         }
         this._topMenu = value;
         this._topMenu.tabPage = this.topBar;
         this.topBar.addEventListener(Event.ACTIVATE,this.reflowButtons);
         this._topMenu.leagueButton = this.btnLeague;
         this._topMenu.clanButton = this.btnClan;
         this._topMenu.rewardsButton = this.btnRewards;
         this._topMenu.faceButton = this.btnChangeName;
         (this._topMenu as TopMenu).setFactionBnt(this.factionsProgress as Button);
      }
      
      public function setPlayerName(value:String) : void
      {
         var textFormat:TextFormat = null;
         var maxMultilineSize:int = 0;
         var textW:int = 0;
         var finalTextSize:int = 0;
         trace("TopPanel.setPlayerName :",value);
         var nickname:TextField = this.panelPlayer.playerInfo.nicknameField as TextField;
         if(nickname)
         {
            textFormat = nickname.getTextFormat();
            textFormat.size = 30;
            nickname.setTextFormat(textFormat);
            nickname.multiline = false;
            nickname.wordWrap = false;
            nickname.text = value;
            if(nickname.textWidth + 4 > nickname.width)
            {
               maxMultilineSize = 20;
               textFormat.size = maxMultilineSize;
               nickname.setTextFormat(textFormat);
               textW = nickname.textWidth + 8;
               if(textW > nickname.width * 2)
               {
                  finalTextSize = maxMultilineSize / (textW / nickname.width);
                  textFormat.size = finalTextSize;
               }
            }
            nickname.wordWrap = true;
            nickname.text = value;
            nickname.height = nickname.textHeight + 4;
            nickname.mouseEnabled = false;
            if(nickname.numLines > 2)
            {
               textFormat.size = 16;
               nickname.setTextFormat(textFormat);
            }
            nickname.height = nickname.textHeight + 4;
            nickname.y = 46 / 2 - nickname.textHeight / 2 - 8;
         }
         this.btnChangeName.visible = true;
      }
      
      public function setPlayerClanAbb(value:String) : void
      {
         this._clanAbb = value;
         this.setPlayerName(PlayerInfo.nickname);
      }
      
      public function setPlayerClanState(value:uint) : void
      {
         this._clanState = value;
         this.setPlayerName(PlayerInfo.nickname);
      }
      
      public function toggleInventoryMode(value:Boolean) : void
      {
         this.btnCogs.visible = value;
         this.factionsProgress.visible = !value;
         this.btnLeagueCurrency.visible = false;
      }
      
      public function setDetails(value:int) : void
      {
         this.btnCogs.content_tf.text = value.toString();
      }
      
      public function setMoneyData(generic:int, premium:uint, league:uint) : void
      {
         this.panelPlayer.playerInfo.hintButton.alpha = 0;
         this.txGeneric.text = Util.getMoneyString(generic);
         this.txGeneric.textColor = generic >= 0 ? 10137262 : 11222333;
         var genericFormat:TextFormat = this.txGeneric.getTextFormat();
         genericFormat.size = 21;
         this.txGeneric.setTextFormat(genericFormat);
         if(this.txGeneric.textWidth > this.txGeneric.width - 4)
         {
            genericFormat.size = Math.floor(21 * ((this.txGeneric.width - 4) / this.txGeneric.textWidth));
            this.txGeneric.setTextFormat(genericFormat);
         }
         this.txPremium.text = Util.getMoneyString(premium);
         this.btnLeagueCurrency.content_tf.text = Util.getMoneyString(league);
         invalidateData();
      }
      
      public function onStageResize(event:Event = null) : void
      {
         if(Boolean(this._changeNicknameMessage) && Boolean(this._changeNicknameMessage.parent))
         {
            this._changeNicknameMessage.y = (MainScene.stageHeight - this._changeNicknameMessage.height) / 2;
         }
         this.background.width = MainScene.stageWidth;
         this.bgSmall.x = MainScene.stageWidth - this.bgSmall.width + 5;
         this.bgSmall2.x = MainScene.stageWidth - (this.btnKnowledgeBase.width + this.btnSettings.width + this.bgSmall2.width - 30) - 5;
         this.reflowButtons();
         invalidate(InvalidationType.SETTINGS);
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         if(this._topMenu)
         {
            this._topMenu.y = 2;
         }
         this.btnRegularMoney.enabled = true;
         this.btnPremiumMoney.enabled = true;
         this.btnPremiumMoney.addEventListener(ButtonEvent.CLICK,this.onPremiumMoneyAddClick);
         this.btnRegularMoney.addEventListener(ButtonEvent.CLICK,this.onRegulatMoneyAddClick);
         this.btnCogs.addEventListener(ButtonEvent.CLICK,this.onCogsAddClick);
         this.btnLeagueCurrency.addEventListener(ButtonEvent.CLICK,this.onLeagueCurrencyClick);
         this.btnShop.visible = false;
         this.btnKnowledgeBase.addEventListener(ButtonEvent.CLICK,this.onKnowlengeBaseClick);
         this.btnSettings.addEventListener(MouseEvent.CLICK,this.onClickSettings);
         this.btnSettings.tooltipRendererName = "SrvTextHintRenderer";
         this.btnPremiumMoney.tooltipRendererName = "SrvTextHintRenderer";
         this.btnRegularMoney.tooltipRendererName = "SrvTextHintRenderer";
         this.panelPlayer.playerInfo.hintButton.tooltipRendererName = "SrvTextHintRenderer";
         this.btnKnowledgeBase.tooltipRendererName = "SrvTextHintRenderer";
         this.btnClan.tooltipRendererName = "SrvTextHintRenderer";
         this.btnRewards.tooltipRendererName = "SrvTextHintRenderer";
         this.btnChangeName.tooltipRendererName = "SrvTextHintRenderer";
         this.btnLeague.tooltipRendererName = "SrvTextHintRenderer";
         LocalizationData.addCallback(this.updateLocalization,"btn_settings_label");
         stage.addEventListener(Event.RESIZE,this.onStageResize);
         this.configureButtons();
      }
      
      private function onBtnClanClick() : void
      {
      }
      
      private function onBtnRewardsClick() : void
      {
      }
      
      private function reflowButtons() : void
      {
         var button:Button = null;
         var w:int = 0;
         var pos:int = 0;
         var maxSize:int = 950;
         this.buttons["button_1"].x = 631 + (MainScene.stageWidth - 263 - 1026 - 631) / 2;
         this.buttons["button_1"].x = this.panelPlayer.width - 5;
         this.buttons["hr_mc"].x = this.buttons["button_1"].x + 4;
         this.buttons["hr_mc"].visible = false;
         for(var i:uint = 0; i < 5; i++)
         {
            button = this.buttons["button_" + String(i + 1)];
            if(i == 0)
            {
               pos = button.x;
            }
            else
            {
               button.x = w + pos;
            }
            button.width = button.textField.textWidth + 15;
            w += button.width - 12;
         }
         var oversize:int = (w - maxSize) / 5;
         for(i = 0; i < 5; i++)
         {
            button = this.buttons["button_" + String(i + 1)];
            button.width -= oversize;
            button.x = int(button.x - oversize * i);
         }
      }
      
      private function configureButtons() : void
      {
         var button:Button = null;
         for(var i:uint = 0; i < 5; i++)
         {
            button = this["button_" + String(i + 1)];
         }
      }
      
      private function onCogsAddClick(e:ButtonEvent) : void
      {
         Message.showMessage("debug",LocalizationData.getName("details_info").toUpperCase());
      }
      
      private function onLeagueCurrencyClick(e:ButtonEvent) : void
      {
         Message.showMessage("debug",LocalizationData.getName("league_currency_info").toUpperCase());
      }
      
      private function onRegulatMoneyAddClick(e:ButtonEvent) : void
      {
         Message.showMessage("exchange",{
            "callBack":"exchange_premium_money",
            "label":LocalizationData.getName("exchange_window_label"),
            "stepSize":1,
            "source":2,
            "target":1,
            "factor":PlayerInfo.premiumExchangeRate,
            "amount":PlayerInfo.premiumMoney
         });
         this.reflowButtons();
      }
      
      override protected function draw() : void
      {
         super.draw();
      }
      
      private function updateLocalization(value:*, value2:*) : void
      {
         this.btnSettings.data = {"name":LocalizationData.getName("btn_settings_label")};
         this.btnPremiumMoney.data = {"name":LocalizationData.getName("btn_add_premium_label")};
         this.btnRegularMoney.data = {"name":LocalizationData.getName("btn_exchange_premium_money")};
         this.btnKnowledgeBase.data = {"name":LocalizationData.getName("btn_knowledge_base")};
         this.btnCogs.label_tf.text = LocalizationData.getName("details");
         this.btnLeagueCurrency.label_tf.text = LocalizationData.getName("league_currency_name");
         this.btnClan.data = {"name":LocalizationData.getName("clan")};
         this.btnRewards.data = {"name":LocalizationData.getName("achievements")};
         this.btnLeague.data = {"name":LocalizationData.getName("leagues")};
         this.btnChangeName.data = {"name":LocalizationData.getName("btn_change_name_label")};
      }
      
      private function onClickSettings() : void
      {
         dispatchEvent(new Event("show_settings",true));
         GameInterface.call("show_settings",uint(0));
      }
      
      public function onPremiumShopClick(e:Event = null) : void
      {
         dispatchEvent(new Event("show_premium_store",true));
      }
      
      public function onPremiumMoneyAddClick(e:Event = null) : void
      {
         // svh: there is no online store; the gold "+" opens the exchange window, whose
         // "Buy gold" row (MessageMoneyExchange) turns silver into gold.
         Message.showMessage("exchange",{
            "callBack":"exchange_premium_money",
            "label":LocalizationData.getName("exchange_window_label"),
            "stepSize":1,
            "source":2,
            "target":1,
            "factor":PlayerInfo.premiumExchangeRate,
            "amount":PlayerInfo.premiumMoney
         });
         this.reflowButtons();
      }
      
      private function showStoreMessage() : void
      {
         var object:Object = {
            "text":LocalizationData.getName("go_to_online_store_message"),
            "acceptCallback":this.goToStore,
            "label_ok":LocalizationData.getName("btn_go_to_online_store"),
            "label_cancel":LocalizationData.getName("cancel")
         };
         Message.showMessage("apply",object,true);
      }
      
      private function onKnowlengeBaseClick(e:Event) : void
      {
         if(this._topMenu as TopMenu)
         {
            if((this._topMenu as TopMenu).askCurrentUIHasChanges(this.show_survival_notes_list,null,null))
            {
               return;
            }
         }
         this.show_survival_notes_list();
      }
      
      public function getNotes() : MovieClip
      {
         return this._notesMessage;
      }
      
      public function show_survival_notes_list(e:Event = null) : void
      {
         var sceneContainer:MovieClip = null;
         if(this._notesVisible)
         {
            return;
         }
         if(MainScene.activePop)
         {
            MainScene.ignoreRemoved = true;
            MainScene.activePop.closeWindow();
         }
         this._notesVisible = true;
         var messData:Object = new Object();
         this._topMenu.deselectMenu();
         var notesList:Array = [{
            "index":0,
            "notesLabel":"prepare_to_battle_notes",
            "label":LocalizationData.getName("prepare_to_battle_notes").toUpperCase(),
            "images":"fight",
            "length":7
         },{
            "index":1,
            "notesLabel":"mode_notes",
            "label":LocalizationData.getName("mode_notes").toUpperCase(),
            "images":"mode",
            "length":8
         },{
            "index":3,
            "notesLabel":"anomaly_notes",
            "label":LocalizationData.getName("anomaly_notes").toUpperCase(),
            "images":"anom",
            "length":8
         },{
            "index":4,
            "notesLabel":"anomaly_type_notes",
            "label":LocalizationData.getName("anomaly_type_notes").toUpperCase(),
            "images":"anomalie",
            "length":4
         },{
            "index":2,
            "notesLabel":"modifications_notes",
            "label":LocalizationData.getName("modifications_notes").toUpperCase(),
            "images":"mod",
            "length":8,
            "locale":MainScene.spriteLocalization
         }];
         messData.notesList = notesList;
         this.btnKnowledgeBase.selected = true;
         var ref:Class = getDefinitionByName("SrvEncyclop") as Class;
         this._notesMessage = new ref();
         this._notesMessage.autoClose = false;
         if(!this._notesMessage.parent)
         {
            this._notesMessage.x = 0;
            this._notesMessage.y = 0;
            sceneContainer = MainScene.stage as MovieClip;
            sceneContainer.addChildAt(this._notesMessage,0);
         }
         MainScene.activePop = this._notesMessage;
         this._notesMessage.setData(messData);
         this._notesMessage.addEventListener(Event.REMOVED_FROM_STAGE,this.onNotesRemoved);
         dispatchEvent(new Event(Events.HIDE_WINDOW,true));
         dispatchEvent(new Event(Events.CLOSE_WINDOW,true));
         dispatchEvent(new Event(Events.ENTER_NAME_SHOWED,true));
         this._topMenu.addEventListener(Event.ACTIVATE,this.closeNotes);
         (this._topMenu as TopMenu).openKnowledge();
      }
      
      private function closeNotes(e:Event = null) : void
      {
         if(Boolean(this._notesMessage) && Boolean(this._notesMessage.parent) && Boolean(e))
         {
            this._notesMessage.closeWindow();
         }
      }
      
      private function onNotesRemoved(e:Event) : void
      {
         this._notesVisible = false;
         this._notesMessage.removeEventListener(Event.REMOVED_FROM_STAGE,this.onNotesRemoved);
         this._topMenu.tabPage.removeEventListener(ListEvent.INDEX_CHANGE,this.closeNotes);
         dispatchEvent(new Event(Events.UNHIDE_WINDOW,true));
         if(!MainScene.tutorialMode)
         {
            dispatchEvent(new Event(Events.SHOW_WINDOWS,true));
         }
         this.btnKnowledgeBase.selected = false;
         if(MainScene.ignoreRemoved)
         {
            MainScene.ignoreRemoved = false;
            return;
         }
         dispatchEvent(new Event(Events.ENTER_NAME_REMOVED,true));
         (this._topMenu as TopMenu).closeKnowledge();
      }
      
      protected function goToStore() : void
      {
         GameInterface.call("go_to_store");
      }
      
      protected function goToKnowledgeBase() : void
      {
         GameInterface.call("go_to_knowledge_base");
      }
      
      public function updateFactionProgressData(inFactionData:Object) : void
      {
         var icon:MovieClip = this.factionsProgress.getChildByName("icon") as MovieClip;
         var progress_bar:StatusIndicator = this.factionsProgress.getChildByName("progress_bar") as StatusIndicator;
         var factionName:TextField = this.factionsProgress.getChildByName("factionName") as TextField;
         TextFieldEx.setVerticalAlign(factionName,TextFieldEx.VALIGN_BOTTOM);
         if(Boolean(inFactionData) && Boolean(inFactionData.faction_label))
         {
            (this.factionsProgress as Button).tipData = {"name":inFactionData.faction_label.toUpperCase()};
         }
         if(inFactionData)
         {
            icon.gotoAndStop(inFactionData.faction_id);
            factionName.text = inFactionData.faction_name.toUpperCase();
            icon.visible = true;
            factionName.visible = true;
            this.factionsProgress.faction_lvl.text = inFactionData.faction_lvl_str;
            TextField(this.factionsProgress.faction_lvl).textColor = Util.getFactionColor(inFactionData.faction_id);
         }
         else
         {
            icon.visible = false;
            factionName.visible = false;
         }
         if(progress_bar)
         {
            progress_bar.maximum = 100;
            if(inFactionData)
            {
               (progress_bar.getChildByName("progressLine") as MovieClip).gotoAndStop(inFactionData.faction_id);
               progress_bar.visible = true;
               progress_bar.value = inFactionData.faction_progress;
            }
            else
            {
               (progress_bar.getChildByName("progressLine") as MovieClip).gotoAndStop(1);
               progress_bar.value = 0;
               progress_bar.visible = false;
            }
         }
      }
      
      public function toggleEquipmentShopMode(value:Boolean) : void
      {
         this.factionsProgress.visible = !value;
         this.btnCogs.visible = false;
         this.btnLeagueCurrency.visible = value;
      }
      
      public function onLogout() : void
      {
         if(this._changeNicknameMessage)
         {
            this._changeNicknameMessage.closeWindow();
         }
         for(var i:uint = 0; i < this.topBar.dataProvider.length; i++)
         {
            this.topBar.dataProvider[i].shine = false;
         }
         this.topBar.dataProvider.invalidate();
      }
      
      public function ignoreIsTypingCheck() : Boolean
      {
         if(Boolean(this._changeNicknameMessage) && Boolean(this._changeNicknameMessage.parent))
         {
            return true;
         }
         return false;
      }
   }
}


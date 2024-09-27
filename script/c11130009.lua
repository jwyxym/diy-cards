--陨宇祀圣 盛飓
local this,id,ofs=GetID()
function this.initial_effect(c)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(this.k3_the_failure_Condition())
	e1:SetOperation(this.k3_the_failure_Operation())
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(this.splimit)
	--c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(this.tdtg)
	e2:SetOperation(this.tdop)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(this.value)
	c:RegisterEffect(e2)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetCondition(this.damcon)
	e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e4)
end
function this.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0xa63)
end
function this.tdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa63)
end
function this.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetMatchingGroupCount(this.tdfilter,tp,LOCATION_ONFIELD+LOCATION_REMOVED,0,nil)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToDeck() end
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,0,0)
end
function this.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 then Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
end
function this.value(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED)*400
end
function this.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil and e:GetHandler():GetSummonType()&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
end
function this.k3_the_failure_Filter(c,fc)
	return c:IsCanBeFusionMaterial(fc)
end
function this.k3_the_failure_SpFilter1(c,fc,tp,mg,chkf)
	return c:IsFusionSetCard(0xa63) and mg:IsExists(this.k3_the_failure_SpFilter2,1,c,fc,tp,c,chkf)
end
function this.k3_the_failure_SpFilter2(c,fc,tp,mc,chkf)
	local sg=Group.FromCards(c,mc)
	if sg:IsExists(aux.TuneMagicianCheckX,1,nil,sg,EFFECT_TUNE_MAGICIAN_F) then return false end
	if not aux.MustMaterialCheck(sg,tp,EFFECT_MUST_BE_FMATERIAL) then return false end
	if aux.FCheckAdditional and not aux.FCheckAdditional(tp,sg,fc)
		or aux.FGoalCheckAdditional and not aux.FGoalCheckAdditional(tp,sg,fc) then return false end
	return chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0
end
function this.k3_the_failure_GCheck(sg)
	if sg:IsExists(aux.TuneMagicianCheckX,1,nil,sg,EFFECT_TUNE_MAGICIAN_F) then return false end
	if not aux.MustMaterialCheck(sg,tp,EFFECT_MUST_BE_FMATERIAL) then return false end
	if aux.FCheckAdditional and not aux.FCheckAdditional(tp,sg,fc)
		or aux.FGoalCheckAdditional and not aux.FGoalCheckAdditional(tp,sg,fc) then return false end
	return sg:GetClassCount(Card.GetRace)==#sg
end
function this.k3_the_failure_Condition()
	return	function(e,g,gc,chkf)
			if g==nil then return aux.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_FMATERIAL) end
			local c=e:GetHandler()
			local mg=g:Filter(this.k3_the_failure_Filter,nil,c)
			local tp=e:GetHandlerPlayer()
			if gc and not mg:IsContains(gc) then return false end
			return mg:IsExists(this.k3_the_failure_SpFilter1,1,nil,c,tp,mg,chkf)
		end
end
function this.k3_the_failure_Operation()
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
			local c=e:GetHandler()
			local mg=eg:Filter(this.k3_the_failure_Filter,nil,c)
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			local g=nil
			if gc then
				g=Group.FromCards(gc)
				mg:RemoveCard(gc)
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
				g=mg:FilterSelect(tp,this.k3_the_failure_SpFilter1,1,1,nil,c,tp,mg,exg,chkf)
				mg:Sub(g)
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
			local sg=mg:SelectSubGroup(tp,this.k3_the_failure_GCheck,false)
			g:Merge(sg)
			Duel.SetFusionMaterial(g)
		end
end

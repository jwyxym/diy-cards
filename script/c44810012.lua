--次元魔盗 可汗 小约翰
local s,id,o=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--融合召唤
	aux.AddFusionProcFunFun(c,s.matfilter,aux.FilterBoolFunction(Card.IsFusionSetCard,0x5ce1),2,true)
    aux.AddContactFusionProcedure(c,s.fcfilter,LOCATION_HAND+LOCATION_MZONE+LOCATION_REMOVED,0,aux.ContactFusionSendToDeck(c))
	c:EnableReviveLimit()
	--翻开
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sdtg)
	e1:SetOperation(s.sdop)
	c:RegisterEffect(e1)
	--攻击上升
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--多次攻击
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(s.bdval)
	c:RegisterEffect(e3)
	--除外
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.rmcon)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)        
end
function s.matfilter(c)
	return c:IsFusionSetCard(0x5ce1) and c:IsFusionType(TYPE_FUSION) and c:GetEquipCount()>0
end
function s.fcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function s.sdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroup(tp,LOCATION_DECK,0):FilterCount(Card.IsAbleToRemove,nil)>0
    	and Duel.GetFieldGroup(tp,0,LOCATION_DECK):FilterCount(Card.IsAbleToRemove,nil)>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_DECK)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.thfilter(c)
	return c:IsSetCard(0x5ce1,0x3ce1) and c:IsAbleToHand()
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanRemove(tp) then return end
	local ct1=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	if ct1>5 then ct1=5 end
    if ct2>5 then ct2=5 end
	if ct1>1 then
		local tbl={}
		for i=1,ct1 do
			table.insert(tbl,i)
		end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
		ct1=Duel.AnnounceNumber(tp,table.unpack(tbl))
	end
    if ct2>1 then
		local tbl={}
		for i=1,ct2 do
			table.insert(tbl,i)
		end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,5))
		ct2=Duel.AnnounceNumber(tp,table.unpack(tbl))
	end
    Duel.ConfirmDecktop(tp,ct1)
	Duel.ConfirmDecktop(1-tp,ct2)
    local g1=Duel.GetDecktopGroup(tp,ct1)
	local g2=Duel.GetDecktopGroup(1-tp,ct2)
    g1:Merge(g2)
    if g1:GetCount()>0 then
    	Duel.DisableShuffleCheck()
    	if g1:FilterCount(s.thfilter,nil)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then    		
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g1:FilterSelect(tp,s.thfilter,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleHand(tp)
			g1:Sub(sg)
   	 	end    	
    	Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
    end
end
function s.atkval(e,c)
	return e:GetHandler():GetEquipCount()*1100
end
function s.bdval(e,c)
	return e:GetHandler():GetEquipCount()-1
end
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetFieldGroup(tp,0,LOCATION_DECK):FilterCount(Card.IsAbleToRemove,nil)>0
    	and c:GetFlagEffect(id)<c:GetEquipCount() end
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	local g=Duel.GetDecktopGroup(1-tp,1)
	Duel.DisableShuffleCheck()
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_REMOVED)
    	and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
		if hg:GetCount()>0 then
        	Duel.HintSelection(hg)
			Duel.SendtoHand(hg,tp,REASON_EFFECT)			
		end
    end
end
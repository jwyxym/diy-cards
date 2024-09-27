--神帝的复生
local m=16110053
local cm=_G["c"..m]
function cm.initial_effect(c)
	--quick
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	c:RegisterEffect(e0)
	--Effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(cm.togtg)
	e1:SetOperation(cm.togop)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
end
function cm.setfilter1(c)
	return c:IsSetCard(0xcc5) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(5) and c:IsAbleToHand()
	and Duel.IsPlayerCanSummon(tp,SUMMON_TYPE_ADVANCE,c) 
end
function cm.togtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and cm.setfilter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.setfilter1,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,cm.setfilter1,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
function cm.togop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetFirstTarget()
	if ct:IsRelateToEffect(e) then
			if ct then
				Duel.SendtoHand(ct,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,ct)
				if ct:IsLocation(LOCATION_HAND)  then
					local e12=Effect.CreateEffect(c)
					e12:SetDescription(aux.Stringid(m,0))
					e12:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
					e12:SetType(EFFECT_TYPE_SINGLE)
					e12:SetCode(EFFECT_SUMMON_PROC)
					e12:SetCondition(cm.sumcon)
					e12:SetOperation(cm.sumop)
					e12:SetValue(SUMMON_TYPE_ADVANCE)
					e12:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END) 
					ct:RegisterEffect(e12)
					local e13=e12:Clone()
					e13:SetCode(EFFECT_SET_PROC)
					ct:RegisterEffect(e13)
					local s1=ct:IsSummonable(true,nil,1)
					local s2=ct:IsMSetable(true,nil,1)
					if (s1 and s2 and Duel.SelectPosition(tp,ct,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
						Duel.Summon(tp,ct,true,nil,1)
					else
						Duel.MSet(tp,ct,true,nil,1)
					end
				end   
			end 
	end
end
function cm.sumcon(e,c)
	return true
end
function cm.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	return true
end
--to hand
function cm.thfilter(c)
	return c:IsSetCard(0xcc5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and not c:IsCode(m)
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

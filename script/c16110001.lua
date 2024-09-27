--谜神帝 伊兹莫
if not pcall(function() require("expansions/script/c16199990") end) then require("script/c16199990") end
local m,cm=rk.set(16110001)
function cm.initial_effect(c)
	--summon with 1 tribute
	local e1,e2=rkst.Tri(c)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,m)
	e3:SetCondition(cm.descon)
	e3:SetTarget(cm.destg)
	e3:SetOperation(cm.desop)
	c:RegisterEffect(e3)
	--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,2))
	e4:SetCategory(CATEGORY_SUMMON+CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_HAND)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(cm.sumcon)
	e4:SetCost(cm.sumcost)
	e4:SetTarget(cm.sumtg)
	e4:SetOperation(cm.sumop)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_HAND,0)
	e5:SetCondition(cm.addcon)
	e5:SetTarget(cm.advtg)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
function cm.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
function cm.filter(c)
	return c:IsAttackAbove(2400) and c:IsDefense(1000) and c:IsAbleToHand()
end
function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
function cm.tgfilter(c)
	return c:IsSetCard(0xcc5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function cm.desop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(cm.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_DECK,0,nil)
	if g1:GetClassCount(Card.GetCode)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg1=g1:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if Duel.SendtoGrave(tg1,REASON_EFFECT)~=0 then
		local og=Duel.GetOperatedGroup()
		local num=0
		for tc in aux.Next(og) do
			if not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,tc,tc:GetCode()) then
				num=num+1
			end
		end
		if num>0 and g:GetCount()>0 then
			local tg=g:Select(tp,1,num,nil)
			Duel.SendtoHand(tg,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
function cm.addcon(e,c)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
function cm.advtg(e,c)
	return c:IsSetCard(0xcc5) and c:IsAttack(2800)
end
function cm.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,e:GetHandler():GetCode())==0
end
function cm.tdfilter(c)
	return c:IsSetCard(0xcc5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeckAsCost() and c:IsFaceup()
end
function cm.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cm.tdfilter,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	Duel.SendtoDeck(tg1,nil,2,REASON_EFFECT)
	Duel.RegisterFlagEffect(tp,c:GetCode(),RESET_PHASE+PHASE_END,0,1)
end
function cm.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
function cm.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local pos=0
	if c:IsSummonable(true,nil,1) then pos=pos+POS_FACEUP_ATTACK end
	if c:IsMSetable(true,nil,1) then pos=pos+POS_FACEDOWN_DEFENSE end
	if pos==0 then return end
	if Duel.SelectPosition(tp,c,pos)==POS_FACEUP_ATTACK then
		Duel.Summon(tp,c,true,nil,1)
	else
		Duel.MSet(tp,c,true,nil,1)
	end
end
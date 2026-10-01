-- 烬雪的狐狩·稔华
local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--P效①：以包含「烬雪」卡的魔陷区2张卡为对象，那些卡回到持有者手卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	s.jinxue_effect=e1
	--怪兽①
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--怪兽②：怪兽区域被破坏时在P区放置
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,id+2)
	e5:SetCondition(s.pencon)
	e5:SetTarget(s.pentg)
	e5:SetOperation(s.penop)
	c:RegisterEffect(e5)
end
-- P效①
function s.cfilter(c)
	return c:IsSetCard(0xe93) and c:IsAbleToHand()
end
function s.tdfilter(c)
	return c:IsAbleToHand()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.tdfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil)
			and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g1=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g2=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,g1)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,g1:GetCount(),0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local rg=g:Filter(Card.IsAbleToHand,nil)
	if #rg>0 then
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
	end
end
-- 怪兽①
function s.hfilter(c)
	return c:IsSetCard(0xe93) and c:IsAbleToDeckOrExtraAsCost()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xe93) and c:GetOriginalType()&TYPE_MONSTER>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=Duel.SelectMatchingCard(tp,s.hfilter,tp,LOCATION_HAND,0,1,1,nil)
	if tg:GetCount()==0 then return end
	Duel.ConfirmCards(1-tp,tg)
	if Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_SZONE,0,nil,e,tp)
	local gc=g:GetCount()
	if gc==0 then return end
	local lc=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if lc<=0 then return end
	local ct=math.min(gc,lc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,ct,nil)
	if sg:GetCount()>0 then
		Duel.SpecialSummon(sg,0,tp,tp,true,true,POS_FACEUP)
	end
end
-- 怪兽②
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_GRAVE)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsLocation(LOCATION_GRAVE) then return end
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
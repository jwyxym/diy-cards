-- 羽隙的微光·芙尔德丽兹
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.EnablePendulumAttribute(c)
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	s.jinxue_effect=e1
  -- 特殊召唤成功时检索+抽卡
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetProperty(EFFECT_FLAG_DELAY)
  e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.thcon)
  e3:SetTarget(s.thtg)
  e3:SetOperation(s.thop)
  c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+2)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_HAND,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_HAND,0,2,2,nil)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.thfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g2:GetCount()>0 then
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g2)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetTargetRange(LOCATION_ONFIELD+LOCATION_HAND,0)
	e1:SetTarget(s.lvfilter)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.lvfilter(e,c)
	return c:IsSetCard(0xe93) and c:IsType(TYPE_RITUAL) and c:IsLevelAbove(1)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.thfilter2(c)
  return c:IsType(TYPE_NORMAL) and c:IsFaceup() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  local ct=math.floor(e:GetHandler():GetLevel()/2)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,ct,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local ct=math.floor(e:GetHandler():GetLevel()/2)
  if ct>0 and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,ct,nil) then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,ct,ct,nil)
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
  end
end
function s.desfilter(c)
	return c:IsSetCard(0xe93)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_PZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_PZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local te=tc.jinxue_effect
		local op=te:GetOperation()
		local tg=te:GetTarget()
		local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
		if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
		if op then
			Duel.Hint(HINT_CARD,0,tc:GetCode())
			op(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end

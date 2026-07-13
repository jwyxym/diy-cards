--魔妖仙兽的风宫
--ID: 44800008
--字段: 妖仙兽(0xb3)
local s,id=GetID()
function s.initial_effect(c)
	--卡的发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--计数效果: 自己回合每次妖仙兽召唤、灵摆召唤成功时，在此卡上记录一次
	local e_count=Effect.CreateEffect(c)

	e_count:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)

	e_count:SetCode(EVENT_SUMMON_SUCCESS)
	e_count:SetRange(LOCATION_SZONE)
	e_count:SetCondition(s.countcon)
	e_count:SetOperation(s.countop)
	c:RegisterEffect(e_count)

	local e_count2=e_count:Clone()

	e_count2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e_count2:SetCondition(s.countcon2)
	c:RegisterEffect(e_count2)

	--①回卡组检索，最多2张，自肃
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))

	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

	--②追加通常召唤妖仙兽怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+1000)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)

	--③送墓自身，从卡组盖放妖仙兽魔陷（需要本回合5次以上召唤·灵摆召唤成功）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOFIELD)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+2000)
	e3:SetCondition(s.condition3)
	e3:SetCost(s.cost3)
	e3:SetTarget(s.target3)
	e3:SetOperation(s.operation3)
	c:RegisterEffect(e3)
end

--计数: 妖仙兽通常召唤成功（自己回合）
function s.countcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()~=tp then return false end
	return eg:IsExists(s.countfilter,1,nil)
end
function s.countfilter(c)
	return c:IsSetCard(0xb3)
end

function s.countop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end

--计数: 妖仙兽灵摆召唤成功（自己回合）
function s.countcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()~=tp then return false end
	return eg:IsExists(function(c) return c:IsSetCard(0xb3) and c:IsSummonType(SUMMON_TYPE_PENDULUM) end,1,nil)
end
--countop复用

--①效果
function s.cfilter1(c)
	return c:IsSetCard(0xb3) and c:IsAbleToDeckAsCost()
end

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,2,nil)
	e:SetLabel(g:GetCount())

	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.thfilter1(c)
	return c:IsSetCard(0xb3) and c:IsAbleToHand()
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if ct==0 then return end

	--自肃: 直到回合结束时自己不是风属性怪兽不能特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,ct,ct,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end

--②效果: 追加召唤妖仙兽怪兽
function s.sumfilter(c)
	return c:IsSetCard(0xb3) and c:IsSummonable(true,nil)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil) end
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end

--③效果
function s.condition3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(id)>=5
end

function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function s.setfilter(c)
	return c:IsSetCard(0xb3) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

function s.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.operation3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
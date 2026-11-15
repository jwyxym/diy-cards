-- 残云封天剑（ID: 61000055）通常魔法
-- 效果文本：
--   这个卡名在规则上也当作「云剑」卡使用。
--   ①：自己主要阶段1开始时才能发动。自己手卡的卡全部除外，给与对方那之中「云剑」卡数量×800的伤害。
local s,id,o=GetID()
s.setcode=0xa7c0

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

-- 自己主要阶段1开始时
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),tp,LOCATION_HAND)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local n=g:FilterCount(s.yjfilter,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if n>0 then Duel.Damage(1-tp,n*800,REASON_EFFECT) end
end

function s.yjfilter(c)
	return c:IsSetCard(s.setcode)
end

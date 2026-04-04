--剧毒公主·梅杜莎
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280146)
    c:SetSPSummonOnce(id)
	--特召规则
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	--多次攻击    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(2)
	c:RegisterEffect(e2)
	--送去墓地    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.tgcon)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end    
function s.sprfilter(c)
	return aux.IsCodeOrListed(c,31280146) and c:IsAbleToDeckOrExtraAsCost() 
    	and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,c)
    	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
    Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,2,REASON_SPSUMMON)
	g:DeleteGroup()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=c:GetBattleTarget()
	e:SetLabelObject(ac)
	return ac and ac:IsFaceup() and ac:IsControler(1-tp)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabelObject()
	if ac:IsFaceup() and ac:IsRelateToBattle() and ac:IsControler(1-tp) 
    	and ac:IsAbleToGrave() then
    	Duel.Hint(HINT_CARD,0,id)
    	Duel.SendtoGrave(ac,REASON_EFFECT)
    end
end
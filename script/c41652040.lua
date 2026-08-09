-- 万物之终结
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,41652000)
	--act in set turn
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,2))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetValue(id)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCondition(s.condition)
	e0:SetCost(s.actcost)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--to grave
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+1+EFFECT_COUNT_CODE_DUEL)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
function s.condition(e)
	return e:GetHandler():IsLocation(LOCATION_HAND)
end
function s.actcfilter(c)
	return not aux.IsCodeOrListed(c,41652000) and c:IsAbleToRemove()
end
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actcfilter,tp,LOCATION_DECK,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.actcfilter,tp,LOCATION_DECK,0,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--自己受到的伤害变为0
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CHANGE_DAMAGE)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,0)
	e0:SetValue(0)
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)
	--不会被战斗破坏
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(s.tgfilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
	--不会被效果破坏
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(s.tgfilter)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	Duel.RegisterEffect(e2,tp)
	--不会成为效果对象
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(s.tgfilter)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetValue(1)
	Duel.RegisterEffect(e3,tp)
end
function s.tgfilter(c)
	return aux.IsCodeOrListed(c,41652000)
end
function s.rmcfilter(c)
	return aux.IsCodeOrListed(c,41652000) and c:IsAbleToRemove()
end
function s.fselect(g)
	return g:GetClassCount(Card.GetOriginalAttribute)==1 and g:IsExists(s.rmcfilter,1,nil)
end
function s.costfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c,e,tp)
end
function s.spfilter(c,tc,e,tp)
	return aux.IsCodeOrListed(c,41652000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	if chk==0 then return g:CheckSubGroup(s.fselect,2,2) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=g:SelectSubGroup(tp,s.fselect,false,2,2)
	if Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,nil,e,tp)
		if sg:GetCount()>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
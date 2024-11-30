local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,51600545)
	aux.EnablePendulumAttribute(c)
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_WIND),s.matfilter,true)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DEFENSE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.targeta)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--to pendulum 1
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
	--to pendulum 2
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)

end
function s.dfilter(c,tp)
	return c:IsFaceup() and aux.IsCodeListed(c,51600545) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED,0,1,nil,c:GetOriginalLevel())
end
function s.filter(c,lv)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_PENDULUM) and c:IsLevelBelow(lv) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,0,nil,tp)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.gcheck(lv)
	return  function(g)
				return aux.dncheck(g) and g:GetSum(Card.GetLevel)<=lv
			end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	if not tc or Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)<1 then return end
	local lv=tc:GetOriginalLevel()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,0,nil,lv)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	aux.GCheckAdditional=s.gcheck(lv)
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,lv)
	aux.GCheckAdditional=nil
	if sg then Duel.SendtoHand(sg,nil,REASON_EFFECT) end
end

function s.matfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_MONSTER)
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(ATTRIBUTE_WIND) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.targeta(e,c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_PENDULUM)
end
function s.cfilter(c)
	return c:IsCode(51600545) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_REMOVED,0,1,nil)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
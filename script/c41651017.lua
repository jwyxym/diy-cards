-- 联翩画龙
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(SUMMON_VALUE_SELF)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--immume
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.imcon)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(84815190,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
function s.rmfilter(c,tp)
  return (c:IsControler(tp) or c:IsFaceup()) and c:IsAbleToRemove()
end
function s.rmfilter2(c,tp)
  return(c:IsControler(tp) or c:IsFaceup()) and c:IsRace(RACE_WYRM) and c:IsAbleToRemove()
end
function s.fselect(g,tp)
	return g:IsExists(s.rmfilter2,4,nil,tp)	and Duel.GetMZoneCount(tp,g)>0
end
function s.spcon(e,c,tp)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	return g:CheckSubGroup(s.fselect,5,5,tp) and aux.GetAttributeCount(g)>=5
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
  local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	aux.GCheckAdditional=aux.dabcheck
	local sg=g:SelectSubGroup(tp,s.fselect,true,5,5,tp)
	aux.GCheckAdditional=nil
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	local atk=g:GetSum(Card.GetPreviousAttackOnField)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	c:RegisterEffect(e1)
	g:DeleteGroup()
end
function s.imcon(e)
	return e:GetHandler():IsAttackAbove(5001)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner() and te:IsActivated()
end
function s.tgfilter(c,e)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:IsCanBeEffectTarget(e) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return aux.GetAttributeCount(tg)>4 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	aux.GCheckAdditional=aux.dabcheck
	local g=tg:SelectSubGroup(tp,aux.TRUE,false,5,5)
	aux.GCheckAdditional=nil
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,nil,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local g1=tg:Filter(Card.IsControler,nil,tp)
	local g2=tg:Filter(Card.IsControler,nil,1-tp)
	local ag1=Duel.GetMatchingGroup(Card.IsControler,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,tg,tp)
	local ag2=Duel.GetMatchingGroup(Card.IsControler,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,tg,1-tp)
	if ag1:GetCount()>0 then
		Duel.SendtoHand(ag1,nil,REASON_RULE,tp)
	end
	if ag2:GetCount()>0 then
		Duel.SendtoHand(ag2,nil,REASON_RULE,1-tp)
	end
end

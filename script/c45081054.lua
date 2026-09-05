--G石人·大地巨人
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	--Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return not eg:IsContains(e:GetHandler()) and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) end)
	c:RegisterEffect(e2)
	--inactivatable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_INACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.effectfilter)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISEFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.effectfilter)
	c:RegisterEffect(e4)
	--
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+1)
	e5:SetTarget(s.damtg)
	e5:SetOperation(s.damop)
	c:RegisterEffect(e5)
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x186)
end
function s.setfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x186) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
function s.effectfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	local tc=te:GetHandler()
	return p==tp and (loc&LOCATION_ONFIELD)~=0 and tc:GetMutualLinkedGroupCount()>0
end
function s.GetLRL(c)
	if c:IsLevelAbove(1) then
		return c:GetLevel()
	elseif c:IsRankAbove(1) then
		return c:GetRank()
	elseif c:IsLinkAbove(1) then
		return c:GetLink()
	else
		return NULL_VALUE 
	end
end
function s.damtgfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsCanBeEffectTarget(e) and s.GetLRL(c)>0 and c:IsPreviousControler(1-tp)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.damtgfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(s.damtgfilter,1,nil,e,tp) end
	local tg=eg
	if #eg>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tg=eg:FilterSelect(tp,s.damtgfilter,1,1,nil,e,tp)
	end
	Duel.SetTargetCard(tg)
	local value=s.GetLRL(tg:GetFirst())*100
	Duel.SetTargetParam(value)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,value)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local value=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if value>0 and Duel.Damage(1-tp,value,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		if #g==0 then return end
		Duel.BreakEffect()
		local tc=g:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(value)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end
--路观大王
--鸣谢来自科学的代码by_Dongkies
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddLinkProcedure(c,s.matfilter,3,99,s.lcheck)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	local e00=Effect.CreateEffect(c)
	e00:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e00:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e00:SetCode(EVENT_ADJUST)
	e00:SetRange(LOCATION_MZONE)
	e00:SetCondition(s.tgcon)
	e00:SetOperation(s.tgop)
	c:RegisterEffect(e00)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_SINGLE)
	e2b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2b:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetValue(1)
	c:RegisterEffect(e2b)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.qcon)
	e3:SetTarget(s.e3tg)
	e3:SetOperation(s.e3op)
	c:RegisterEffect(e3)
end


function s.cfilter(c)
	return c:GetSequence()>4
end
function s.matfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_DRAGON+RACE_THUNDER+RACE_PSYCHO,lc,sumtype,tp)
end
function s.lcheck(g,lc,sumtype,tp)
	local exc=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if #exc>0 then return g:GetClassCount(Card.GetLinkRace)>=3 and g:IsContains(exc:GetFirst()) end
	if #exc==0 then return g:GetClassCount(Card.GetLinkRace)>=3 end
end


function s.splimit(e,se,sp,st)
    return st & SUMMON_TYPE_SPECIAL ~= SUMMON_TYPE_SPECIAL 
        or (st & LOCATION_EXTRA) == LOCATION_EXTRA
end


function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:GetSequence()<5
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
		Duel.SendtoGrave(c,REASON_RULE)
	end
end


function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	return math.max(Duel.GetLP(tp)-6000,0)
end


function s.atlimit(e,c)
	return c==e:GetHandler()
end


function s.protected(c)
	return c:IsFaceup() and c:IsCode(id)
end
function s.dircon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.protected,tp,LOCATION_MZONE,0,1,nil)
		and not Duel.IsExistingMatchingCard(aux.NOT(s.protected),tp,LOCATION_MZONE,0,1,nil)
end


function s.qcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)==0
end
function s.e3filter(c)
	return c:IsFaceup() and (c:IsAttackAbove(0) or c:IsDefenseAbove(0))
end
function s.e3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3filter,tp,0,LOCATION_MZONE,1,nil)
	end
end
function s.e3op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local ct=0
    while ct<8 and Duel.IsExistingMatchingCard(s.qfilter,tp,0,LOCATION_MZONE,1,nil) do
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g=Duel.GetMatchingGroup(s.qfilter,tp,0,LOCATION_MZONE,1,nil)
        local tc=g:RandomSelect(tp,1):GetFirst()
        local pre_atk=tc:GetAttack()
        local pre_def=tc:GetDefense()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-800)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(e2)
        local atk0=pre_atk>0 and tc:GetAttack()==0
        local def0=not tc:IsType(TYPE_LINK) and pre_def>0 and tc:GetDefense()==0
        if tc:IsFaceup() and tc:IsDestructable() and (atk0 or def0) then
            Duel.Destroy(tc,REASON_EFFECT)
        end
        ct=ct+1
    end
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		 local e3=Effect.CreateEffect(c)
		 e3:SetType(EFFECT_TYPE_SINGLE)
		 e3:SetCode(EFFECT_UPDATE_ATTACK)
		 e3:SetValue(ct*300)
		 e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		 c:RegisterEffect(e3)
	end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end

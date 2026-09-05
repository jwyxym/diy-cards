--姦淫的随从
local s,id,o=GetID()
function s.initial_effect(c)
	--特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--回复    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o*10000)
	e2:SetCondition(s.rccon)
	e2:SetTarget(s.rctg)
	e2:SetOperation(s.rcop)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
	e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.efcon)
    e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
end
function s.confilter(c)
	return c:IsSetCard(0x5ca1) and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLP(tp)>=400
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if Duel.GetLP(tp)>=400 then
    	Duel.PayLPCost(tp,400)
    end    
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.rccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_FUSION)
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,800)
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(tp,800,REASON_EFFECT)
	Duel.Recover(1-tp,800,REASON_EFFECT)
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and c:IsReason(REASON_EFFECT)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Recover(tp,800,REASON_EFFECT)~=0 and Duel.Recover(1-tp,800,REASON_EFFECT)~=0 then
    	Duel.BreakEffect()
        local c=e:GetHandler()
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(s.regcon)
		e1:SetOperation(s.regop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
    	local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVED)
		e2:SetCondition(s.lpcon)
		e2:SetOperation(s.lpop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
    end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsAttribute(ATTRIBUTE_DARK) and rc:IsRace(RACE_FIEND) and re:IsActiveType(TYPE_MONSTER)
    	and rp==tp 
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	rc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsAttribute(ATTRIBUTE_DARK) and rc:IsRace(RACE_FIEND) and re:IsActiveType(TYPE_MONSTER)
    	and rp==tp and rc:GetFlagEffect(id)>0
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Recover(tp,400,REASON_EFFECT)
end
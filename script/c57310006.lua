--破式的变貌·菲绫
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,57310005)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetValue(57310001)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SSET)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e2:SetCountLimit(1,id)
    e2:SetCost(s.setcost)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+id)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
    return c:IsRace(RACE_SPELLCASTER) or c:IsRace(RACE_ILLUSION)
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.CheckLPCost(tp,1000)
            and c:IsReleasable() and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
    end
    Duel.PayLPCost(tp,1000)
    Duel.Release(c,REASON_COST)
	local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
    return not (c:IsRace(RACE_SPELLCASTER) or c:IsRace(RACE_ILLUSION))
end
function s.setfilter(c)
    return c:IsType(TYPE_SPELL) and aux.IsCodeListed(c,57310005) and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SSET,nil,1,tp,LOCATION_DECK)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 then return end
    local tc=g:GetFirst()
    if Duel.SSet(tp,tc)~=0 then
        if Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)>0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
            e1:SetRange(LOCATION_SZONE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            e1:SetValue(1)
            tc:RegisterEffect(e1)
		end
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetReleaseGroup(tp)
    if chk==0 then return g:CheckSubGroup(aux.mzctcheckrel,1,1,tp) and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local rg=g:SelectSubGroup(tp,aux.mzctcheckrel,false,1,1,tp)
    aux.UseExtraReleaseCount(rg,tp)
    Duel.Release(rg,REASON_COST)
	local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    Duel.RegisterEffect(e1,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e1:SetValue(LOCATION_REMOVED)
            c:RegisterEffect(e1)
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
			e5:SetRange(LOCATION_MZONE)
			e5:SetValue(1)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e5)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
			e2:SetRange(LOCATION_MZONE)
			e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(s.atlimit)
			c:RegisterEffect(e2)
        end
        Duel.SpecialSummonComplete()
    end
end
function s.atlimit(e,c)
    return c~=e:GetHandler()
end
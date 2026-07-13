--心火 烬勇
local s,id,o=GetID()
local o=o*10000
function s.initial_effect(c)
	aux.EnableChangeCode(c,61000001,LOCATION_MZONE)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_HAND)
  e2:SetCountLimit(1,id+o)
  e2:SetCost(s.cost)
  e2:SetTarget(s.target)
  e2:SetOperation(s.operation)
  c:RegisterEffect(e2)
	c:RegisterEffect(e2)
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,2))
	e3a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a:SetProperty(EFFECT_FLAG_DELAY)
	e3a:SetCode(EVENT_TO_GRAVE)
  e3a:SetCountLimit(1,id+o)
	e3a:SetCondition(s.matcon)
	e3a:SetTarget(s.mattg)
	e3a:SetOperation(s.matop)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3b:SetCode(EVENT_TO_GRAVE)
	e3b:SetCondition(s.matcon2)
	c:RegisterEffect(e3b)
	local ex=Effect.CreateEffect(c)
	ex:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	ex:SetCode(EVENT_SPSUMMON_SUCCESS)
	ex:SetOperation(s.spop3)
	c:RegisterEffect(ex)
end


function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
function s.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsDiscardable()
end


function s.tgfilter(c,tp,eg)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsControler(tp) and c:IsRace(RACE_ZOMBIE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,tp)
	end
	if chk==0 then
		return e:GetHandler():IsLocation(LOCATION_GRAVE)
			and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)) then return end
	Duel.Overlay(tc,Group.FromCards(c))
	local og=tc:GetOverlayGroup()
	if #og==0 then return end
	local g=og:Filter(s.xfilter,nil)
	if #g==0 then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
function s.xfilter(c)
	return (c:IsSetCard(0x37c0) and c:IsType(TYPE_SPELL+TYPE_TRAP))
		or (c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER))
end


function s.costfilter(c,tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        if not c:IsAbleToGraveAsCost() then return false end
        local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND,0,c)
        return g:GetCount()>=1 and #g>=1
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
    g:AddCard(c)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end


function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY) 
        and re and re:GetHandler():IsType(TYPE_XYZ)
end
function s.matcon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
    end
end
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_XYZ)
end
function s.thfilter(c,sc)
    return (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x37C0))
        or (c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER))
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local xg=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
    local xc=xg:GetFirst()
    if xc and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) then
        Duel.Overlay(xc,Group.FromCards(c))
        local og=xc:GetOverlayGroup()
        if og:IsExists(s.thfilter,1,nil,0x37C0) 
            and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=og:FilterSelect(tp,s.thfilter,1,1,nil,0x37C0)
            if #sg>0 then
                Duel.SendtoHand(sg,tp,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
            end
        end
    end
end


function s.spop3(e,tp,eg,ep,ev,re,r,rp,c)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsRace(RACE_ZOMBIE)
end
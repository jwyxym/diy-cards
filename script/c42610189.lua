--Re:从零开始的异世界生活 爱蜜莉雅
local cm,m=GetID()

function cm.initial_effect(c)
    aux.AddCodeList(c,10700512)
    c:EnableCounterPermit(0x1015)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,m)
    e1:SetCondition(cm.regcon)
	e1:SetTarget(cm.tdtg)
	e1:SetOperation(cm.tdop)
	c:RegisterEffect(e1)
    --
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,m+1)
    e2:SetCondition(cm.thcon)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(cm.adval)
	c:RegisterEffect(e6)
end
cm.counter_add_list={0x1015}
function cm.lckfilter(c)
    return c:IsLinkRace(RACE_SPELLCASTER) or c:IsLinkAttribute(ATTRIBUTE_WATER)
end

function cm.lcheck(g,lc)
	return g:IsExists(cm.lckfilter,1,nil)
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x1015,5) end
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsCanAddCounter(0x1015,5) and c:AddCounter(0x1015,5) then
        local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,0x0c,nil,0x1015,1)
        if #g>0 then
            for tc in aux.Next(g) do
                tc:AddCounter(0x1015,1)
            end
        end
    end
end

function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
    return re:GetHandler():GetCounter(0x1015)>=1
end

function cm.tgthfilter(c,e,tp)
    return (aux.IsCounterAdded(c,0x1015) or c:IsCode(3070049,15893860,24661486,32750510)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return c:IsReleasableByEffect() and Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(cm.tgthfilter,tp,0x01,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,c,1,nil,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x01)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.Release(c,REASON_EFFECT) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,cm.tgthfilter,tp,0x01,0,1,1,nil,e,tp)
        if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
            local rg=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,0x0c,nil,0x1015,2)
            if #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
                for tc in aux.Next(rg) do
                    tc:AddCounter(0x1015,2)
                end
            end
        end
    end
end

function cm.adval(e,c)
	return Duel.GetCounter(tp,0x0c,0x0c,0x1015)*100
end
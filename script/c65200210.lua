local s,id=GetID()
local NM=0x32a

if not _G.NM_RELEASE_65200210 then
    _G.NM_RELEASE_65200210 = true
    local ge=Effect.GlobalEffect()
    ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge:SetCode(EVENT_RELEASE)
    ge:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        for tc in aux.Next(eg) do
            if tc:GetPreviousControler()==tp and tc:IsRace(RACE_ZOMBIE) then
                Duel.RegisterFlagEffect(tp, 65200210, RESET_PHASE+PHASE_END, 0, 1)
            end
        end
    end)
    Duel.RegisterEffect(ge, 0)
end

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_RELEASE+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id+200)
    e4:SetCondition(s.gycon)
    e4:SetTarget(s.gytg)
    e4:SetOperation(s.gyop)
    c:RegisterEffect(e4)
end

function s.spfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(2)
end
function s.spcon(e,tp)
    if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil) then return true end
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    local attrs={}
    local tc=g:GetFirst()
    while tc do
        attrs[tc:GetAttribute()]=true
        tc=g:GetNext()
    end
    local count=0
    for _ in pairs(attrs) do count=count+1 end
    return count>=2
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,200)
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,0,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,0,1-tp,LOCATION_ONFIELD)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    -- ●注册：本回合自己不死族怪兽被解放时给对方200伤害，最多5次
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_RELEASE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetLabel(0)
    e1:SetOperation(s.dmgop)
    Duel.RegisterEffect(e1,tp)

    -- 尽可能解放自己场上怪兽
    local g=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_MZONE,0,nil)
    local ct=#g
    if ct==0 then return end

    Duel.Release(g,REASON_EFFECT)

    -- 根据解放数量，选对方场上的卡回到手卡
    local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
    if dg:GetCount()>0 then
        local num=math.min(ct,dg:GetCount())
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local sg=dg:Select(tp,num,num,nil)
        if #sg>0 then
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
        end
    end
end

-- ●处理：每次自己不死族怪兽被解放时给200伤害，最多5次
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    if ct>=5 then return end
    for tc in aux.Next(eg) do
        if tc:GetPreviousControler()==tp and tc:IsRace(RACE_ZOMBIE) then
            if ct>=5 then return end
            Duel.Damage(1-tp,200,REASON_EFFECT)
            ct=ct+1
            e:SetLabel(ct)
        end
    end
end

function s.gycon(e,tp)
    return Duel.GetFlagEffect(tp,65200210)>0
end
function s.gyfilter(c,e,tp)
    return c:IsSetCard(NM) and c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
function s.splimit(e,c)
    return not c:IsRace(RACE_ZOMBIE)
end
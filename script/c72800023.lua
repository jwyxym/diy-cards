-- ！TOGENASHI TOGEARI！
-- ID: 72800023
-- 暗属性 / 幻想魔族 / 超量
-- 12星怪兽×5
-- 「TOGENASHI TOGEARI」字段：0xb15
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()

    -- 标准超量召唤：12星怪兽×5
    aux.AddXyzProcedure(c, nil, 12, 5)

    -- 替代超量召唤：自己场上有5种属性不同的「TOGENASHI TOGEARI」超量怪兽时，把它们作为超量素材重叠召唤
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.altcon)
    e1:SetTarget(s.alttg)
    e1:SetOperation(s.altop)
    c:RegisterEffect(e1)

    -- 1种类以上：不会被战斗破坏
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetCondition(s.cond1)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- 3种类以上：不受「TOGENASHI TOGEARI」卡以外的效果影响
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetCondition(s.cond3)
    e3:SetValue(s.immval)
    c:RegisterEffect(e3)

    -- 5种类以上：1回合1次，对方场上的卡全部无效并破坏
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.cond5)
    e4:SetTarget(s.eff5tg)
    e4:SetOperation(s.eff5op)
    c:RegisterEffect(e4)

    -- ② 被送去墓地的场合，从自己墓地选「TOGENASHI TOGEARI」超量怪兽5种类各1只特殊召唤
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1,id+1)
    e5:SetTarget(s.sp5tg)
    e5:SetOperation(s.sp5op)
    c:RegisterEffect(e5)
end

-- 统计超量素材中不同属性的种类数
function s.countattr(c)
    local mg=c:GetOverlayGroup()
    if not mg then return 0 end
    local attrs={}
    local cnt=0
    local tc=mg:GetFirst()
    while tc do
        local a=tc:GetAttribute()
        if a and a>0 and not attrs[a] then
            attrs[a]=true
            cnt=cnt+1
        end
        tc=mg:GetNext()
    end
    return cnt
end

-- 效果条件
function s.cond1(e)
    return s.countattr(e:GetHandler())>=1
end
function s.cond3(e)
    return s.countattr(e:GetHandler())>=3
end
function s.cond5(e)
    return s.countattr(e:GetHandler())>=5
end

-- 3种类以上：仅免疫非「TOGENASHI TOGEARI」卡的效果
function s.immval(e,re)
    if not re then return true end
    local rc=re:GetHandler()
    if rc and rc:IsSetCard(0xb15) then return false end
    return true
end

-- 5种类以上：对方场上的卡全部无效并破坏
function s.eff5tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.eff5op(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
    if #g==0 then return end
    local tc=g:GetFirst()
    while tc do
        if tc:IsFaceup() and tc:IsType(TYPE_EFFECT) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
        end
        tc=g:GetNext()
    end
    Duel.Destroy(g,REASON_EFFECT)
end

-- 替代超量召唤：场上「TOGENASHI TOGEARI」超量怪兽
function s.altfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xb15) and c:IsType(TYPE_XYZ)
end
function s.altcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return false end
    local mg=Duel.GetMatchingGroup(s.altfilter,tp,LOCATION_MZONE,0,nil)
    if #mg<5 then return false end
    local attrs={}
    local cnt=0
    local tc=mg:GetFirst()
    while tc do
        local a=tc:GetAttribute()
        if a and a>0 and not attrs[a] then
            attrs[a]=true
            cnt=cnt+1
        end
        tc=mg:GetNext()
    end
    return cnt>=5
end
function s.alttg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    if chk==0 then return true end
    local mg=Duel.GetMatchingGroup(s.altfilter,tp,LOCATION_MZONE,0,nil)
    local selected=Group.CreateGroup()
    local usedattrs={}
    for i=1,5 do
        local avail=Group.CreateGroup()
        local tc=mg:GetFirst()
        while tc do
            local a=tc:GetAttribute()
            if a and a>0 and not usedattrs[a] then
                avail:AddCard(tc)
            end
            tc=mg:GetNext()
        end
        if #avail==0 then return false end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
        local sg=avail:Select(tp,1,1,nil)
        local tc2=sg:GetFirst()
        if not tc2 then return false end
        selected:AddCard(tc2)
        mg:RemoveCard(tc2)
        usedattrs[tc2:GetAttribute()]=true
    end
    selected:KeepAlive()
    e:SetLabelObject(selected)
    return true
end
function s.altop(e,tp,eg,ep,ev,re,r,rp,c)
    local selected=e:GetLabelObject()
    if selected and #selected==5 then
        -- 关键修复：先清空被叠放怪兽的原有超量素材，避免贴图残留
        local tc=selected:GetFirst()
        while tc do
            local og=tc:GetOverlayGroup()
            if og and og:GetCount()>0 then
                Duel.SendtoGrave(og,REASON_RULE)
            end
            tc=selected:GetNext()
        end
        Duel.Overlay(c,selected)
    end
end

-- ② 墓地特殊召唤：5种不同卡名的「TOGENASHI TOGEARI」超量怪兽
function s.sp5filter(c,e,tp)
    return c:IsSetCard(0xb15) and c:IsType(TYPE_XYZ)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sp5tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.sp5filter,tp,LOCATION_GRAVE,0,nil,e,tp)
        local codes={}
        local cnt=0
        local tc=g:GetFirst()
        while tc do
            local code=tc:GetCode()
            if not codes[code] then
                codes[code]=true
                cnt=cnt+1
            end
            tc=g:GetNext()
        end
        return cnt>=5
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,5,tp,LOCATION_GRAVE)
end
function s.sp5op(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.sp5filter,tp,LOCATION_GRAVE,0,nil,e,tp)
    local selected=Group.CreateGroup()
    local usedcodes={}
    for i=1,5 do
        local avail=g:Filter(function(tc)
            return not usedcodes[tc:GetCode()]
        end,nil)
        if #avail==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=avail:Select(tp,1,1,nil)
        local tc=sg:GetFirst()
        if not tc then return end
        selected:AddCard(tc)
        g:RemoveCard(tc)
        usedcodes[tc:GetCode()]=true
    end
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<5 then return end
    local tc=selected:GetFirst()
    while tc do
        Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
        tc=selected:GetNext()
    end
    Duel.SpecialSummonComplete()
end
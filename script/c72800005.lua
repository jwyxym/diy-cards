-- 薄明の序奏
-- ID: 72800005
-- 属性：暗 / 种族：幻想魔族 / 类型：融合
-- 「TOGENASHI TOGEARI」字段：0xb15
-- 「Iseri Nina」：72800000
-- 「GIRLS BAND CRY」：72800002
-- 注：星级、ATK、DEF 由数据库设定
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddCodeList(c,72800000,72800002)
    aux.AddMaterialCodeList(c,72800000)
    aux.AddMaterialCodeList(c,72800002)

    -- 融合召唤：「Iseri Nina」+「GIRLS BAND CRY」
    aux.AddFusionProcCode2(c,72800000,72800002,true,true)

    -- 只能用融合召唤或替代方法特殊召唤
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(s.splimit)
    c:RegisterEffect(e0)

    -- 替代召唤方法：弃1张魔法·陷阱 + 解放1只「TOGENASHI TOGEARI」怪兽（1回合1次）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCountLimit(1,id+1)
    e1:SetCondition(s.altcon)
    e1:SetTarget(s.alttg)
    e1:SetOperation(s.altop)
    c:RegisterEffect(e1)

    -- ① 特殊召唤成功时，从卡组把1张「TOGENASHI TOGEARI」魔法在自己场上盖放
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SSET)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)

    -- ② 自己场上的「TOGENASHI TOGEARI」场地魔法卡被效果破坏时，可作为代替把这张卡送去墓地
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTarget(s.reptg)
    e3:SetValue(s.repval)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)
end

-- 特殊召唤限制：只允许融合召唤（替代方法通过 UNCOPYABLE 绕过）
function s.splimit(e,se,sp,st)
    return st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
end

-- 替代召唤：弃1张魔法·陷阱 + 解放1只「TOGENASHI TOGEARI」怪兽
function s.spellfilter(c)
    return (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsDiscardable()
end
function s.relfilter(c)
    return c:IsSetCard(0xb15) and c:IsType(TYPE_MONSTER) and c:IsReleasable()
end

function s.altcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return false end
    if not Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_HAND,0,1,c) then return false end
    return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c)
end

function s.alttg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c)
    if #g==0 then return false end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local rg=g:Select(tp,1,1,nil)
    if #rg==0 then return false end
    e:SetLabelObject(rg:GetFirst())
    return true
end

function s.altop(e,tp,eg,ep,ev,re,r,rp,c)
    local tc=e:GetLabelObject()
    if tc then
        if tc:IsLocation(LOCATION_MZONE) then
            Duel.Release(tc,REASON_COST)
        else
            Duel.SendtoGrave(tc,REASON_COST+REASON_RELEASE)
        end
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local g=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_HAND,0,1,1,c)
    if #g>0 then Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD) end
end

-- ① 盖放对象：「TOGENASHI TOGEARI」魔法
function s.setfilter(c)
    return c:IsSetCard(0xb15) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then Duel.SSet(tp,g:GetFirst()) end
end

-- ② 代替破坏：「TOGENASHI TOGEARI」场地魔法被效果破坏时，代替送去墓地
function s.repfilter(c,tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_FZONE)
        and c:IsSetCard(0xb15)
        and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return eg:IsExists(s.repfilter,1,nil,tp) and c:IsAbleToGrave()
    end
    return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoGrave(c,REASON_EFFECT+REASON_REPLACE)
    end
end
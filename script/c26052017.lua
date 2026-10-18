-- 暗夜织者的狩猎者 洛蕾莱·纳赫特
-- ID: 26052017
-- 字段：暗夜织者 0x912
-- 8星/暗/仪式/昆虫族
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()

    -- ① 对方不能把场上的这张卡解放
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CANNOT_BE_RELEASE_MATERIAL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.rellimit)
    c:RegisterEffect(e1)

    -- ② 已仪式召唤时，无效对方效果并装备
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)

    -- ③ 对方结束阶段，没有攻击宣言的对方怪兽全部破坏
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
end

-- ① 对方不能解放
function s.rellimit(e,c)
    return c:GetControler()~=e:GetHandlerPlayer()
end

-- ② 条件：已仪式召唤，对方发动场上/墓地效果
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    if not e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) then return false end
    local rc=re:GetHandler()
    if not rc then return false end
    return rc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE)
end

function s.negfilter(c,tp)
    return c:IsFaceup() and c:IsControler(1-tp) and c:IsType(TYPE_EFFECT)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_MZONE)
            and chkc:IsControler(1-tp)
            and s.negfilter(chkc,tp)
    end
    if chk==0 then
        return Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_MZONE,1,nil,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_MZONE,1,2,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    -- 无效化对方发动的效果
    Duel.NegateEffect(ev)

    local c=e:GetHandler()
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if not g then return end
    local tg=g:Filter(Card.IsRelateToEffect,nil,e)
    if #tg==0 then return end

    for tc in aux.Next(tg) do
        -- 无效化目标怪兽的效果（在装备前注册）
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)

        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)

        -- 当作装备魔法卡装备给这张卡
        if Duel.Equip(tp,tc,c,true) then
            -- 攻击力上升2000
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_EQUIP)
            e3:SetCode(EFFECT_UPDATE_ATTACK)
            e3:SetValue(2000)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e3)

            -- 装备限制：只能装备给这张卡
            local e4=Effect.CreateEffect(c)
            e4:SetType(EFFECT_TYPE_SINGLE)
            e4:SetCode(EFFECT_EQUIP_LIMIT)
            e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e4:SetValue(s.eqlimit)
            e4:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e4)
        end
    end
end

function s.eqlimit(e,c)
    return e:GetOwner()==c
end

-- ③
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end

function s.dfilter(c,tp)
    return c:IsFaceup()
        and c:IsControler(1-tp)
        and not c:IsHasEffect(EFFECT_ATTACKED)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.dfilter,tp,0,LOCATION_MZONE,1,nil,tp)
    end
    local g=Duel.GetMatchingGroup(s.dfilter,tp,0,LOCATION_MZONE,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.dfilter,tp,0,LOCATION_MZONE,nil,tp)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
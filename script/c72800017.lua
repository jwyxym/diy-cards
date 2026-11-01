-- 蝶に結いた赤い糸
-- ID: 72800017
-- 场地魔法
-- 「TOGENASHI TOGEARI」字段：0xb15
local s,id=GetID()
function s.initial_effect(c)
    -- 卡的发动
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- ① 每次自己把「TOGENASHI TOGEARI」怪兽特殊召唤时，自己场上全部怪兽攻击力上升300
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCondition(s.atkcon)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    -- ② 从手卡丢弃1张卡，宣言1个同名卡不在自己场上存在的「TOGENASHI TOGEARI」怪兽卡名，从卡组加入手卡
    -- 无总次数限制，仅限制同一卡名本回合不能重复宣言
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_ANNOUNCE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    -- 移除了 SetCountLimit(1)，不再限制总次数
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- ① 条件：自己把「TOGENASHI TOGEARI」怪兽特殊召唤
function s.spfilter(c,tp)
    return c:IsSetCard(0xb15) and c:IsControler(tp)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spfilter,1,nil,tp)
end
-- ① 操作：自己场上全部表侧怪兽攻击力上升300（永久）
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    local tc=g:GetFirst()
    while tc do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(300)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        tc=g:GetNext()
    end
end

-- ② cost：从手卡丢弃1张卡
function s.costfilter(c)
    return c:IsDiscardable()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end

-- ② 宣告过滤器：卡组中的「TOGENASHI TOGEARI」怪兽，同名卡不在自己场上，且本回合未被宣言过
function s.anfilter(c,tp)
    return c:IsSetCard(0xb15) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
        and not Duel.IsExistingMatchingCard(s.anexfilter,tp,LOCATION_MZONE,0,1,nil,c:GetCode())
        and not c:IsHasEffect(id,tp)
end
function s.anexfilter(c,code)
    return c:IsFaceup() and c:IsCode(code)
end
-- ② 检索过滤器：匹配宣言卡名
function s.thfilter(c,code)
    return c:IsSetCard(0xb15) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
        and c:IsCode(code)
end

-- ② 目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.anfilter,tp,LOCATION_DECK,0,1,nil,tp) end
    local g=Duel.GetMatchingGroup(s.anfilter,tp,LOCATION_DECK,0,nil,tp)
    local ag=Group.CreateGroup()
    local codes={}
    local tc=g:GetFirst()
    while tc do
        local code=tc:GetCode()
        if not ag:IsExists(Card.IsCode,1,nil,code) then
            ag:AddCard(tc)
            table.insert(codes,code)
        end
        tc=g:GetNext()
    end
    table.sort(codes)
    local afilter={codes[1],OPCODE_ISCODE}
    if #codes>1 then
        for i=2,#codes do
            table.insert(afilter,codes[i])
            table.insert(afilter,OPCODE_ISCODE)
            table.insert(afilter,OPCODE_OR)
        end
    end
    ag:Clear()
    local ncodes={}
    local exg=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,nil,0xb15)
    local tc2=exg:GetFirst()
    while tc2 do
        local code=tc2:GetCode()
        if not ag:IsExists(Card.IsCode,1,nil,code) then
            ag:AddCard(tc2)
            table.insert(ncodes,code)
        end
        tc2=exg:GetNext()
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
    local ac=Duel.AnnounceCard(tp,table.unpack(afilter))
    local af={
        TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT,
        0xb15,OPCODE_ISSETCARD,OPCODE_AND,
        TYPE_MONSTER,OPCODE_ISTYPE,OPCODE_AND
    }
    for i=1,#ncodes do
        table.insert(af,ncodes[i])
        table.insert(af,OPCODE_ISCODE)
        table.insert(af,OPCODE_NOT)
        table.insert(af,OPCODE_AND)
    end
    getmetatable(e:GetHandler()).announce_filter=af
    Duel.SetTargetParam(ac)
    Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    -- 注册“该卡名本回合已被宣言”的标记效果
    local e0=Effect.CreateEffect(e:GetHandler())
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(id)
    e0:SetTargetRange(1,0)
    e0:SetTarget(s.thlimit)
    e0:SetLabel(ac)
    e0:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e0,tp)
end
function s.thlimit(e,c,tp,re)
    return c:IsCode(e:GetLabel())
end

-- ② 操作：加入手卡，并施加「TOGENASHI TOGEARI」特殊召唤自肃
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,ac)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
    -- 自肃：本回合只能特殊召唤「TOGENASHI TOGEARI」怪兽
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
    return not c:IsSetCard(0xb15)
end
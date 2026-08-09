local s,id,o=GetID()
function s.initial_effect(c)
    aux.AddLinkProcedure(c, s.singlefilter,2,2,s.lkcheck)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.cond1)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+id)
    e2:SetCondition(s.cond2)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
    if not s.global_check then
        s.global_check=true
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_SUMMON_SUCCESS)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
        local ge2=ge1:Clone()
        ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
        Duel.RegisterEffect(ge2,0)
    end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    while tc do
        Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE+PHASE_END,0,1)
        tc=eg:GetNext()
    end
end
function s.singlefilter(c)
    return c:IsRace(RACE_BEASTWARRIOR)
end

function s.lkcheck(g,tp,lv,scard)
    g:IsExists(s.mfilter,1,nil)
end
function s.mfilter(c)
    return c:IsLinkCode(57300013)
end
-- ①效果条件：本回合召唤·特殊召唤合计≥5
function s.cond1(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(1-tp,id)>=5
end

-- 检索目标：记述了「吉尔达利娅」（密码57300009）的怪兽
function s.thfilter(c)
    return aux.IsCodeListed(c,57300009) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ②效果条件：对方回合
function s.cond2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end

-- 可选连接怪兽：兽战士族连接怪兽
function s.lmfilter(c,tc)
    return c:IsType(TYPE_LINK) and c:IsRace(RACE_BEASTWARRIOR) and c:IsLinkSummonable(nil,tc)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.lmfilter,tp,LOCATION_EXTRA,0,1,nil,c)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local g=Duel.GetMatchingGroup(s.lmfilter,tp,LOCATION_EXTRA,0,nil,nil,c)
    if g:GetCount()>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.LinkSummon(tp,sg:GetFirst(),nil,c)
    end
end
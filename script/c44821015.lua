-- 绽放争艳的「R」
-- ID: 44821015
-- 速攻魔法
-- 记述「Roselia」(44821000)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,44821000)

    -- ① 选择两个效果之一发动
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- ② 墓地存在，记述「Roselia」的融合怪兽从自己场上离开时返回手卡
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,3))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)          -- 添加延迟标志，避免错过时点
    e2:SetCountLimit(1,id+1000)                   -- 调整计数ID，避免与其他卡冲突
    e2:SetCondition(s.reccon)
    e2:SetTarget(s.rectg)
    e2:SetOperation(s.recop)
    c:RegisterEffect(e2)
end

-- ① 可检索对象：记述「Roselia」的卡
function s.thfilter(c)
    return aux.IsCodeListed(c,44821000) and c:IsAbleToHand()
end

-- ① 融合素材过滤：场上·墓地的怪兽，可除外
function s.matfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end

-- ① 融合怪兽过滤：记述「Roselia」的融合怪兽
function s.ffilter(c,e,tp,mg)
    return aux.IsCodeListed(c,44821000) and c:IsType(TYPE_FUSION)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and c:CheckFusionMaterial(mg,nil,PLAYER_NONE)
end

-- ① 目标：选择效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil)
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    local mg=Group.CreateGroup()
    mg:Merge(Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil))
    mg:Merge(Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil))
    local b2=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)

    if chk==0 then return b1 or b2 end

    local ops={}
    local opval={}
    if b1 then
        ops[#ops+1]=aux.Stringid(id,1)
        opval[#opval+1]=1
    end
    if b2 then
        ops[#ops+1]=aux.Stringid(id,2)
        opval[#opval+1]=2
    end
    local sel=opval[Duel.SelectOption(tp,table.unpack(ops))+1]
    e:SetLabel(sel)

    if sel==1 then
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    elseif sel==2 then
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE+LOCATION_GRAVE)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    end
end

-- ① 操作
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local sel=e:GetLabel()
    if sel==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
        if #g==0 then return end
        if Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)==0 then return end

        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #sg>0 then
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
        end
    elseif sel==2 then
        local mg=Group.CreateGroup()
        mg:Merge(Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil))
        mg:Merge(Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil))
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
        local sc=sg:GetFirst()
        if not sc then return end
        local mat=Duel.SelectFusionMaterial(tp,sc,mg,nil,PLAYER_NONE)
        if mat:GetCount()==0 then return end
        sc:SetMaterial(mat)
        Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
        Duel.BreakEffect()
        Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        sc:CompleteProcedure()
    end
end

-- ② 条件：记述「Roselia」的融合怪兽从自己场上离开
function s.revfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
        and c:GetPreviousTypeOnField()&TYPE_FUSION~=0
        and aux.IsCodeListed(c,44821000)
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.revfilter,1,nil,tp)
end

-- ② 目标
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

-- ② 操作：此卡加入手卡
function s.recop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end
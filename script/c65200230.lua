local s,id=GetID()

function s.initial_effect(c)
    -- ①-1 手卡·场上解放
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    -- ①-2 卡组解放
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
end

function s.ritual_filter(c,e,tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_RITUAL)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end

-- ①-1 目标
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.ritual_filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

-- ①-1 处理
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local rg=Duel.SelectMatchingCard(tp,s.ritual_filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #rg==0 then return end
    local rc=rg:GetFirst()
    local rlevel=rc:GetLevel()
    if rlevel<=0 then return end

    -- 获取所有可解放的怪兽
    local mg=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
    if mg:GetCount()==0 then return end

    -- 检查是否存在等级 >= rlevel 的祭品
    local high=mg:Filter(function(c) return c:GetLevel()>=rlevel end,nil)
    local sg
    if high:GetCount()>0 then
        -- 有高等级祭品，只能解放其中1只
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        sg=high:Select(tp,1,1,nil)
    else
        -- 没有高等级祭品，循环解放直到合计等级 >= rlevel
        sg=Group.CreateGroup()
        local sum=0
        local pool=mg:Clone()
        while sum<rlevel do
            if pool:GetCount()==0 then return end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
            local sel=pool:Select(tp,1,1,nil)
            if sel:GetCount()==0 then return end
            local tc=sel:GetFirst()
            sg:AddCard(tc)
            sum=sum+tc:GetLevel()
            pool:RemoveCard(tc)
        end
    end
    if sg:GetCount()==0 then return end

    Duel.Release(sg,REASON_COST+REASON_MATERIAL+REASON_RITUAL)

    if Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
        rc:CompleteProcedure()
    end
end

-- ①-2 目标
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.ritual_filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
            and Duel.IsExistingMatchingCard(function(c)
                return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
            end,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

-- ①-2 处理
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local rg=Duel.SelectMatchingCard(tp,s.ritual_filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #rg==0 then return end
    local rc=rg:GetFirst()
    local rlevel=rc:GetLevel()
    if rlevel<=0 then return end

    local f=function(c) return c:IsRace(RACE_ZOMBIE) and c:IsLevel(rlevel) and c:IsAbleToGrave() end
    if not Duel.IsExistingMatchingCard(f,tp,LOCATION_DECK,0,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local dg=Duel.SelectMatchingCard(tp,f,tp,LOCATION_DECK,0,1,1,nil)
    if #dg==0 then return end
    Duel.SendtoGrave(dg,REASON_COST+REASON_MATERIAL+REASON_RITUAL)

    if Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
        rc:CompleteProcedure()
    end
end
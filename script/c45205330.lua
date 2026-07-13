--推理魔术-逻辑融合 (45205330)
--字段：侦探/融合
--速攻魔法卡

local s,id=GetID()

function s.initial_effect(c)
    -- 规则上也当作「侦探」卡使用
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetValue(0x1D5C)
    c:RegisterEffect(e0)
    
    --①效果：丢弃1张手卡，二选一
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- 丢弃1张手卡作为cost
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- 选项1：融合召唤过滤（侦探怪兽）
function s.fusfilter(c)
    return c:IsSetCard(0x1D5C) and c:IsType(TYPE_FUSION)
end

function s.fmatfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end

-- 选项2：特殊召唤过滤（侦探怪兽）
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x1D5C) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local b1 = false
        local mg = Duel.GetMatchingGroup(s.fmatfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
        if #mg>0 then
            local fg = Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil)
            local fc=fg:GetFirst()
            while fc do
                if fc:CheckFusionMaterial(mg,nil,tp) then
                    b1 = true
                    break
                end
                fc=fg:GetNext()
            end
        end
        local b2 = Duel.GetLocationCountFromEx(tp,tp)>0 
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
        return b1 or b2
    end
    
    -- ★★★ 检查选项1是否可用 ★★★
    local b1 = false
    local mg = Duel.GetMatchingGroup(s.fmatfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    if #mg>0 then
        local fg = Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil)
        local fc=fg:GetFirst()
        while fc do
            if fc:CheckFusionMaterial(mg,nil,tp) then
                b1 = true
                break
            end
            fc=fg:GetNext()
        end
    end
    
    -- ★★★ 如果选项1不可用，直接执行选项2（特殊召唤） ★★★
    if not b1 then
        e:SetLabel(2)
        e:SetCategory(CATEGORY_SPECIAL_SUMMON)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
        return
    end
    
    -- ★★★ 两个都可用时才弹窗选择 ★★★
    local opts={}
    table.insert(opts, aux.Stringid(id,1))
    table.insert(opts, aux.Stringid(id,2))
    local op=Duel.SelectOption(tp,table.unpack(opts))+1
    e:SetLabel(op)
    if op==1 then
        e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    else
        e:SetCategory(CATEGORY_SPECIAL_SUMMON)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    
    if op==1 then
        -- 选项1：融合召唤侦探怪兽
        local mg=Duel.GetMatchingGroup(s.fmatfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
        if #mg==0 then return end
        
        local fg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil)
        if #fg==0 then return end
        
        -- ★★★ 只选能融合的 ★★★
        local ava=fg:Filter(function(c) return c:CheckFusionMaterial(mg,nil,tp) end, nil)
        if #ava==0 then return end
        
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local fc=ava:Select(tp,1,1,nil):GetFirst()
        if not fc then return end
        
        local mat=Duel.SelectFusionMaterial(tp,fc,mg,nil,tp)
        if not mat or #mat==0 then return end
        
        Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
        Duel.BreakEffect()
        Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        fc:CompleteProcedure()
    else
        -- ★★★ 选项2：从额外卡组特殊召唤侦探怪兽（效果无效化） ★★★
        if Duel.GetLocationCountFromEx(tp,tp)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
        if #g>0 then
            local tc=g:GetFirst()
            Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
            -- 效果无效化
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
        end
    end
end
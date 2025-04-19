--怨念龙 厄运装机
local s,id,o=GetID()
function s.initial_effect(c)
    --splimit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetValue(s.splimit)
	c:RegisterEffect(e4)
    -- 效果①
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    -- 效果②
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id+o)
    e2:SetOperation(s.drawop)
    c:RegisterEffect(e2)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1600) end
    Duel.PayLPCost(tp,1600)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.rolldice(tp,count)
    local res={}
    for i=1,count do
        res[i]=Duel.TossDice(tp,1)
    end
    return res
end

function s.countdice(res,check)
    local count=0
    for _,num in ipairs(res) do
        if num==check then count=count+1 end
    end
    return count
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    
    local res=s.rolldice(tp,10)
    
    local six=s.countdice(res,6)
    local one=s.countdice(res,1)
    local other=10-six-one
    
    if six>=6 then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
        Debug.Message("幸运之门扉：早已敞开")
    elseif one>=6 then
        if Duel.SelectYesNo(tp,aux.Stringid(id,0))~=0 and Duel.CheckLPCost(tp,3200) then
            Duel.PayLPCost(tp,3200)
            local res2=s.rolldice(tp,10)
            if s.countdice(res2,6)>=3 then
                Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
                Debug.Message("此即：厄运之示")
            end
        end
    elseif other>=6 then
        if Duel.CheckLPCost(tp,3200) then
            Duel.PayLPCost(tp,3200)
            Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
            Debug.Message("无法逃避：扣下扳机的代价")
        end
    end
end

function s.drawop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local lp=Duel.GetLP(tp)
    if lp>=8000 then
        Duel.Draw(tp,2,REASON_EFFECT)
    elseif lp<=7999 and lp>6000 then
        Duel.Draw(tp,1,REASON_EFFECT)
    elseif lp<=6000 and lp>4000 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
        e1:SetValue(c:GetDefense()*2)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    elseif lp<=4000 then
        Duel.Draw(1-tp,1,REASON_EFFECT)
    end
end
function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
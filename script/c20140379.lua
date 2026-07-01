local s,id,o=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddFusionProcCodeFunRep(c,20140365,aux.FilterBoolFunction(Card.IsAttackBelow,1000),1,127,true,true)
    -- ① 破坏代替→送表侧魔法
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DESTROY_REPLACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(s.reptg)
    e1:SetValue(s.repval)
    e1:SetOperation(s.repop)
    c:RegisterEffect(e1)
    -- ② 特召→抽卡（3体以上抽2）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
    -- ③ 主阶/战阶→送融合→复制效果
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+o)
    e3:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e3:SetCondition(s.sccon)
    e3:SetCost(s.cost3)
    e3:SetOperation(s.op3)
    c:RegisterEffect(e3)
end
-- ①
function s.repfilter(c,tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
        and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
        and Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_ONFIELD,0,1,nil) end
    return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
function s.spellfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE) end
end
-- ②
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp) Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local ct=1
    local mat3=e:GetHandler():GetMaterialCount()>=3
    if mat3 and Duel.IsPlayerCanDraw(tp,2) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then ct=2 end
    Duel.Draw(tp,ct,REASON_EFFECT)
end
-- ③
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
function s.fusfilter3(c)
    return c:IsSetCard(0x46)
        and c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD) and c:IsAbleToGraveAsCost() and c:CheckActivateEffect(true,true,false)~=nil
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.fusfilter3,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.fusfilter3,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
    local tc=g:GetFirst()
    Duel.SendtoGrave(g,REASON_COST)
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(true,true,true)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	Duel.ClearOperationInfo(0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
    local fc=e:GetLabelObject()
    local fe=fc:CheckActivateEffect(true,true,true)
    if fe then
	    local op=fe:GetOperation()
		if op then
			Duel.BreakEffect()
			op(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end

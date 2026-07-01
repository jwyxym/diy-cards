--哥布林远程部队（融合怪兽）
--卡密ID: 45205513
--字段代码: 0xAC

local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()
	
	--接触融合手续（用 EFFECT_SPSUMMON_PROC）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	--特殊召唤条件限制：只能通过接触融合特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)
	
	--不能作为融合素材
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	
	--①效果：除外场上·墓地1张哥布林卡，选场上1张卡除外
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e4:SetCountLimit(1,id+100)
	e4:SetCost(s.rmcost)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	
	--②效果：这张卡被除外的场合，把卡组上方3张卡除外
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_REMOVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,id+200)
	e5:SetTarget(s.removetg)
	e5:SetOperation(s.removeop)
	c:RegisterEffect(e5)
end

--接触融合素材条件
function s.cfilter1(c)
	return c:IsCode(45205503)  -- 哥布林远程部队（主卡组）
end

function s.cfilter2(c)
	return c:IsSetCard(0xAC) and c:IsType(TYPE_MONSTER) and not c:IsCode(45205503)
end

--特殊召唤条件
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g1=Duel.GetMatchingGroup(s.cfilter1,tp,LOCATION_ONFIELD,0,nil)
	local g2=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_ONFIELD,0,nil)
	return #g1>=1 and #g2>=1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

--特殊召唤操作（直接在这里选素材并除外）
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择「哥布林远程部队」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_ONFIELD,0,1,1,nil)
	if #g1==0 then return end
	
	-- 选择另一只哥布林怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_ONFIELD,0,1,1,nil)
	if #g2==0 then return end
	
	-- 合并素材并除外
	local mat=g1:Clone()
	mat:Merge(g2)
	Duel.Remove(mat,POS_FACEUP,REASON_SPSUMMON)
	
	-- 特殊召唤这张卡
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	c:CompleteProcedure()
end

--只能通过接触融合特殊召唤
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end

--①效果Cost：把自己场上·墓地1张哥布林卡除外
function s.rmcostfilter(c)
	return c:IsSetCard(0xAC) and c:IsAbleToRemoveAsCost()
end

function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.rmcostfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmcostfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

--①效果：选场上1张卡除外
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0xff,0xff,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0xff,0xff,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end

--②效果：把卡组上方3张卡除外
function s.removetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
end

function s.removeop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,3)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
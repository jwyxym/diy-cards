-- 纹章兽 孔雀 (ID: 98765401)
local s,id,o=GetID()
function s.initial_effect(c)
	-- ①：自己场上有「纹章兽」怪兽召唤·特殊召唤的场合，或自己场上有念动力族超量怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id) -- ①效果 HOPT
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.spcon2)
	c:RegisterEffect(e2)

	-- ②：只要这张卡在怪兽区域存在，从额外卡组只能把「纹章兽」怪兽或「No.」超量怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	c:RegisterEffect(e3)

	-- ③：这张卡为让卡的效果发动而被送去墓地的场合，或被「No.」超量怪兽的效果送去墓地的场合才能发动。从自己墓地把1张「纹章」卡加入手卡，或把除外状态的1张「纹章」卡回到墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o*100) -- 修正：遵循规则 1.6，使用 id+o*100 彻底杜绝撞车
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end

-- ==================== ① 效果：特召触发自跳并抽卡 ====================
function s.cfilter1(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x76)
end

function s.cfilter2(c,tp)
	return c:IsFaceup() and c:IsControler(tp)
		and (c:IsSetCard(0x76) or (c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ)))
end

function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter1,1,nil,tp)
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil,tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 修正：只有特召成功后才执行 BreakEffect 与抽卡，防止特召失败无条件抽卡 BUG
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

-- ==================== ② 效果：额外特召自锁 ====================
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
		and not c:IsSetCard(0x76)
		and not (c:IsSetCard(0x48) and c:IsType(TYPE_XYZ))
end

-- ==================== ③ 效果：送墓回收「纹章」卡/墓地放置 ====================
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_COST) then return true end
	if c:IsReason(REASON_EFFECT) and re then
		local rc=re:GetHandler()
		if rc and rc:IsSetCard(0x48) and rc:IsType(TYPE_XYZ) then return true end
	end
	return false
end

function s.thfilter(c)
	return (c:IsSetCard(0x76) or c:IsSetCard(0x92)) and c:IsAbleToHand()
end

function s.retfilter(c)
	return (c:IsSetCard(0x76) or c:IsSetCard(0x92)) and c:IsAbleToGrave()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.retfilter,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	if b1 then Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE) end
	if b2 then Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_REMOVED) end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.retfilter,tp,LOCATION_REMOVED,0,1,nil)
	if not b1 and not b2 then return end
	if b1 and (not b2 or Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif b2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.retfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
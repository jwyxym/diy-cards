-- 纹章的觉醒 (ID: 98765407)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 关联卡片 Passcode（不明: 77571455）
	aux.AddCodeList(c,77571455)

	-- ①：从自己的手卡·卡组把 1 只「纹章兽」怪兽表侧表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_SUMMON+TIMING_SPSUMMON+TIMING_FLIPSUMMON+TIMING_MAIN_END)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) -- 这个卡名的卡 1 回合只能发动 1 张
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ②：这张卡在墓地存在的场合，自己把念动力族「No.」超量怪兽超量召唤的场合才能发动。把这张卡加入手卡。那之后，可以把对方场上的表侧表示的卡的卡名当作「不明」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o*100) -- 遵循规则 1.6，使用 id+o*100 杜绝撞车
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- ==================== ① 效果：特召「纹章兽」并加自锁 ====================
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x76) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end

	-- 誓约限制：这个效果的发动后，直到回合结束时自己若非以原本卡名包含「纹章兽」或「No.」的怪兽为素材的超量召唤则不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.matfilter_check(c)
	return c:IsOriginalSetCard(0x76) or c:IsOriginalSetCard(0x48)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	-- 仅限制额外卡组特殊召唤
	if c:IsLocation(LOCATION_EXTRA) then
		-- 非超量召唤（融合/同调/连接）直接禁止
		if sumtype&SUMMON_TYPE_XYZ~=SUMMON_TYPE_XYZ then return true end
		local mg=c:GetMaterial()
		-- 预览检查放行；实际召唤时要求素材组中必须包含原本属于「纹章兽」(0x76) 或「No.」(0x48) 的怪兽
		if not mg or #mg==0 then return false end
		return not mg:IsExists(s.matfilter_check,1,nil)
	end
	return false
end

-- ==================== ② 效果：念动力族「No.」超量召唤触发回收与改名 ====================
function s.cfilter(c,tp)
	-- 正确校验 RACE_PSYCHO 种族宏与 SUMMON_TYPE_XYZ
	return c:GetSummonPlayer()==tp and c:IsSummonType(SUMMON_TYPE_XYZ)
		and c:IsRace(RACE_PSYCHO) and c:IsSetCard(0x48) and c:IsType(TYPE_XYZ)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 独立校验：只检查本卡能否回收，不视对方场上有无卡片
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,c)
		-- 那之后：仅在对方场上有表侧卡片时，弹窗询问并执行改名
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			for tc in aux.Next(g) do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CHANGE_CODE)
				e1:SetValue(77571455)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end